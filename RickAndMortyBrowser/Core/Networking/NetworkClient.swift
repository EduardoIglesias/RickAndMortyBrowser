//
//  NetworkClient.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

protocol NetworkClient: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct DefaultNetworkClient: NetworkClient {
    private let decoder: JSONDecoder
    private let session: URLSession

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.makeURLRequest()

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.transportError(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.httpStatus(http.statusCode, data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
