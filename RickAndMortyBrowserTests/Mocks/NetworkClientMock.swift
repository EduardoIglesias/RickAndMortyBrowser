//
//  NetworkClientMock.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

actor NetworkClientMock: NetworkClient {

    private var results: [Result<Any, Error>] = []
    private var endpoints: [Endpoint] = []

    func enqueueSuccess(_ value: Any) {
        results.append(.success(value))
    }

    func enqueueFailure(_ error: Error) {
        results.append(.failure(error))
    }

    func capturedEndpoints() -> [Endpoint] { endpoints }
    func callCount() -> Int { endpoints.count }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        endpoints.append(endpoint)

        guard !results.isEmpty else {
            preconditionFailure("NetworkClientMock: no enqueued result for request(_:).")
        }

        let next = results.removeFirst()
        switch next {
        case .success(let value):
            guard let typed = value as? T else {
                preconditionFailure("NetworkClientMock: enqueued value type mismatch. Expected \(T.self), got \(type(of: value)).")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}
