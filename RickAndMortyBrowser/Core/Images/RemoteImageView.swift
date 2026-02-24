//
//  RemoteImageView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Combine
import SwiftUI
import UIKit

@MainActor
final class RemoteImageViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case success
        case failure
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var image: UIImage?

    private var task: Task<Void, Never>?
    private var currentURL: URL?

    func load(url: URL?, retries: Int = 2) {
        // If it's the same URL and we already have an image, don't reset/reload.
        if url == currentURL, image != nil {
            return
        }

        // If URL changed, cancel previous task.
        if url != currentURL {
            task?.cancel()
            currentURL = url
            image = nil
            state = .idle
        }

        guard let url else {
            state = .failure
            return
        }

        // If we are already loading this URL, do nothing.
        if state == .loading {
            return
        }

        state = .loading

        task = Task {
            do {
                let img = try await ImagePipeline.shared.image(for: url, retries: retries)
                self.image = img
                self.state = .success
            } catch {
                // Don't mark failure if the task was cancelled (cell disappeared)
                if Task.isCancelled { return }
                self.state = .failure
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

struct RemoteImageView<Placeholder: View>: View {
    let url: URL?
    let retries: Int
    let placeholder: () -> Placeholder

    @StateObject private var vm = RemoteImageViewModel()

    init(url: URL?, retries: Int = 2, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.retries = retries
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = vm.image {
                Image(uiImage: image).resizable()
            } else {
                placeholder()
            }
        }
        .onAppear { vm.load(url: url, retries: retries) }
        .onChange(of: url) { _, newValue in vm.load(url: newValue, retries: retries) }
        .onDisappear { vm.cancel() }
    }
}
