//
//  NetworkErrorDummy.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

enum NetworkErrorDummy {
    static func http404(body: String? = nil) -> NetworkError {
        .httpStatus(404, body?.data(using: .utf8))
    }

    static func http500(body: String? = nil) -> NetworkError {
        .httpStatus(500, body?.data(using: .utf8))
    }

    static func decodingFailed() -> NetworkError {
        .decodingFailed
    }

    static func invalidResponse() -> NetworkError {
        .invalidResponse
    }

    static func transportError(_ message: String = "Transport error") -> NetworkError {
        .transportError(message)
    }

    static func invalidURL() -> NetworkError {
        .invalidURL
    }
}
