//
//  RickAndMortyAPITests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("RickAndMortyAPI")
struct RickAndMortyAPITests {

    @Test
    func charactersEndpoint_includesPage_andOptionalName() throws {
        let endpoint = RickAndMortyAPI.characters(page: 2, name: "Rick")

        let request = try endpoint.makeURLRequest()
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        let items = components?.queryItems ?? []

        #expect(endpoint.path == "character")
        #expect(items.contains(where: { $0.name == "page" && $0.value == "2" }))
        #expect(items.contains(where: { $0.name == "name" && $0.value == "Rick" }))
    }

    @Test
    func characterEndpoint_hasCorrectPath() throws {
        let endpoint = RickAndMortyAPI.character(id: 10)

        let request = try endpoint.makeURLRequest()
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)

        #expect(components?.path.hasSuffix("/api/character/10") == true)
        #expect(endpoint.queryItems.isEmpty == true)
    }
}
