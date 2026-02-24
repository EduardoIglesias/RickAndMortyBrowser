//
//  EndpointTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("Endpoint")
struct EndpointTests {

    @Test
    func makeURLRequest_buildsURL_method_andHeaders() throws {
        guard let base = URL(string: "https://example.com/api") else {
            #expect(Bool(false))
            return
        }

        let endpoint = Endpoint(
            baseURL: base,
            path: "character",
            queryItems: [
                URLQueryItem(name: "page", value: "2"),
                URLQueryItem(name: "name", value: "Rick")
            ]
        )

        let request = try endpoint.makeURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")

        let components = URLComponents(url: request.url ?? base, resolvingAgainstBaseURL: false)
        #expect(components?.path == "/api/character")
        let items = components?.queryItems ?? []
        #expect(items.contains(where: { $0.name == "page" && $0.value == "2" }))
        #expect(items.contains(where: { $0.name == "name" && $0.value == "Rick" }))
    }
}
