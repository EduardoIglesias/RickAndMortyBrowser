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
    func fetchCharacters_buildsCorrectEndpoint_andReturnsDTO() async throws {
        let client = NetworkClientMock()
        let sut = await DefaultCharactersRemoteDataSource(client: client)

        let expected = CharactersResponseDTODummy.make(
            results: [CharacterDTODummy.make(id: 1, name: "Rick")],
            nextPage: 2,
            nameFilter: "Rick"
        )
        await client.enqueueSuccess(expected)

        let dto = try await sut.fetchCharacters(page: 2, nameFilter: "Rick")
        await #expect(dto.results.first?.id == 1)
        await #expect(dto.info.next != nil)

        let endpoints = await client.capturedEndpoints()
        #expect(endpoints.count == 1)

        guard let endpoint = endpoints.first else {
            #expect(Bool(false))
            return
        }

        #expect(endpoint.path == "character")
        #expect(endpoint.queryItems.contains(where: { $0.name == "page" && $0.value == "2" }))
        #expect(endpoint.queryItems.contains(where: { $0.name == "name" && $0.value == "Rick" }))
    }

    @Test
    func fetchCharacter_buildsCorrectEndpoint_andReturnsDTO() async throws {
        let client = NetworkClientMock()
        let sut = await DefaultCharactersRemoteDataSource(client: client)

        let expected = CharacterDTODummy.make(id: 10, name: "Morty")
        await client.enqueueSuccess(expected)

        let dto = try await sut.fetchCharacter(id: 10)
        #expect(dto.id == 10)
        #expect(dto.name == "Morty")

        let endpoints = await client.capturedEndpoints()
        #expect(endpoints.count == 1)

        guard let endpoint = endpoints.first else {
            #expect(Bool(false))
            return
        }

        #expect(endpoint.path == "character/10")
        #expect(endpoint.queryItems.isEmpty)
    }

    @Test
    func fetchCharacters_whenClientThrows_propagatesError() async {
        let client = NetworkClientMock()
        let sut = await DefaultCharactersRemoteDataSource(client: client)

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
