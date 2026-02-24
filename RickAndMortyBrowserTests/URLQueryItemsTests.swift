//
//  URLQueryItemsTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("URL+QueryItems")
struct URLQueryItemsTests {

    @Test
    func appendingQueryItems_addsItems() {
        guard let base = URL(string: "https://example.com/api/character") else {
            Issue.record("Failed to create base URL")
            return
        }

        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "name", value: "Rick")
        ]
        let url = try! #require(components?.url)

        let components2 = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = components2?.queryItems ?? []
        #expect(items.contains(where: { $0.name == "page" && $0.value == "1" }))
        #expect(items.contains(where: { $0.name == "name" && $0.value == "Rick" }))
    }

    @Test
    func appendingQueryItems_withEmptyList_hasNoQueryItems() throws {
        guard let base = URL(string: "https://example.com/api/character") else {
            Issue.record("Failed to create base URL")
            return
        }

        let url = base.appendingQueryItems([])

        let components = try! #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.path == "/api/character")
        #expect((components.queryItems ?? []).isEmpty)
    }
}

