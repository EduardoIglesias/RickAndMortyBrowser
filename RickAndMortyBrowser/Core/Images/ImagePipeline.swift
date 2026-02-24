//
//  ImagePipeline.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import UIKit

actor ImagePipeline {
    static let shared = ImagePipeline()

    private var inFlight: [URL: Task<UIImage, Error>] = [:]

    func image(for url: URL, retries: Int = 2) async throws -> UIImage {
        if let cached = ImageCache.shared.get(url) { return cached }
        if let task = inFlight[url] { return try await task.value }

        let task = Task.detached(priority: .utility) { [url] () throws -> UIImage in
            var remaining = retries
            while true {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                          let image = UIImage(data: data) else {
                        throw URLError(.badServerResponse)
                    }
                    ImageCache.shared.set(image, for: url)
                    return image
                } catch {
                    if remaining <= 0 { throw error }
                    remaining -= 1
                    try? await Task.sleep(for: .milliseconds(150))
                }
            }
        }

        inFlight[url] = task
        defer { inFlight[url] = nil }

        return try await task.value
    }

    func prefetch(_ urls: [URL], retries: Int = 1) {
        for url in urls {
            Task.detached(priority: .utility) {
                _ = try? await ImagePipeline.shared.image(for: url, retries: retries)
            }
        }
    }
}
