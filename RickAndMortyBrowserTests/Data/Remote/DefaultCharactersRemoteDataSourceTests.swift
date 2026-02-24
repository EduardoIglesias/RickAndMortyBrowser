//
//  DefaultCharactersRemoteDataSourceTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("DefaultCharactersRemoteDataSource")
struct DefaultCharactersRemoteDataSourceTests {

    @Test
    @MainActor
    func fetchCharacters_buildsCorrectEndpoint_andReturnsDTO() async throws {
        let client = NetworkClientMock()
        let sut = DefaultCharactersRemoteDataSource(client: client)

        let expected = CharactersResponseDTODummy.make(
            results: [CharacterDTODummy.make(id: 1, name: "Rick")],
            nextPage: 2,
            nameFilter: "Rick"
        )
        await client.enqueueSuccess(expected)

        let dto = try await sut.fetchCharacters(page: 2, nameFilter: "Rick")
        let firstResultID = dto.results.first?.id
        let hasNext = dto.info.next != nil
        #expect(firstResultID == 1)
        #expect(hasNext)

        let endpoints = await client.capturedEndpoints()
        #expect(endpoints.count == 1)

        guard let endpoint = endpoints.first else {
            #expect(Bool(false))
            return
        }

        // Capture actor-isolated properties into local values BEFORE using them in expectations
        let path: String = endpoint.path
        let queryItems: [URLQueryItem] = endpoint.queryItems
        let hasPage2 = queryItems.contains(where: { item in
            let name = item.name
            let value = item.value
            return name == "page" && value == "2"
        })
        let hasNameRick = queryItems.contains(where: { item in
            let name = item.name
            let value = item.value
            return name == "name" && value == "Rick"
        })

        #expect(path == "character")
        #expect(hasPage2)
        #expect(hasNameRick)
    }

    @Test
    @MainActor
    func fetchCharacter_buildsCorrectEndpoint_andReturnsDTO() async throws {
        let client = NetworkClientMock()
        let sut = DefaultCharactersRemoteDataSource(client: client)

        let expected = CharacterDTODummy.make(id: 10, name: "Morty")
        await client.enqueueSuccess(expected)

        let dto = try await sut.fetchCharacter(id: 10)
        let id = dto.id
        let name = dto.name
        #expect(id == 10 && name == "Morty")

        let endpoints = await client.capturedEndpoints()
        #expect(endpoints.count == 1)

        guard let endpoint = endpoints.first else {
            #expect(Bool(false))
            return
        }

        // Capture actor-isolated properties into local values BEFORE using them in expectations
        let path: String = endpoint.path
        let isQueryEmpty: Bool = endpoint.queryItems.isEmpty

        #expect(path == "character/10")
        #expect(isQueryEmpty)
    }

    @Test
    @MainActor
    func fetchCharacters_whenClientThrows_propagatesError() async {
        let client = NetworkClientMock()
        let sut = DefaultCharactersRemoteDataSource(client: client)

        await client.enqueueFailure(NetworkErrorDummy.http500(body: "Boom"))

        do {
            _ = try await sut.fetchCharacters(page: 1, nameFilter: nil)
            #expect(Bool(false))
        } catch {
            // Swift Testing: validamos que hay error (si quieres, lo tipamos)
            #expect(true)
        }
    }
}

