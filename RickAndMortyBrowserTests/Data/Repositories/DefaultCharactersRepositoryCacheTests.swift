//
//  DefaultCharactersRepositoryCacheTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("DefaultCharactersRepository - cache behavior")
struct DefaultCharactersRepositoryCacheTests {

    @Test
    @MainActor
    func fetchCharacter_afterListFetch_usesCache_andDoesNotCallRemoteDetail() async throws {
        // Given
        let remote = CharactersRemoteDataSourceMock()

        let listedID = 42
        let listedDTO = CharacterDTODummy.make(id: listedID, name: "Listed \(listedID)")

        let pageDTO = CharactersResponseDTODummy.make(
            results: [listedDTO],
            nextPage: nil
        )

        await remote.succeedFetchCharacters(page: 1, nameFilter: nil, response: pageDTO)

        // If repository mistakenly calls remote detail, it will return DIFFERENT data
        let remoteDetailDTO = CharacterDTODummy.make(id: listedID, name: "Remote \(listedID)")
        await remote.succeedFetchCharacter(id: listedID, dto: remoteDetailDTO)

        let repository = DefaultCharactersRepository(remote: remote, pageSize: 10)

        // When: fetch list (this should populate cache)
        let (items, _) = try await repository.fetchCharacters(page: 1, nameFilter: nil)
        #expect(items.contains(where: { $0.id == listedID }))

        // And: request detail for an ID that came from list
        let detail = try await repository.fetchCharacter(id: listedID)

        // Then: it should come from cache (i.e., "Listed", not "Remote")
        #expect(detail.id == listedID)
        #expect(detail.name == "Listed \(listedID)")

        let detailCalls = await remote.fetchCharacterCallCount()
        #expect(detailCalls == 0)

        let listCalls = await remote.fetchCharactersCallCount()
        #expect(listCalls == 1)
    }


    @Test
    @MainActor
    func fetchCharacter_cacheMiss_callsRemoteOnce_thenCaches() async throws {
        // Given
        let remote = CharactersRemoteDataSourceMock()
        let repository = DefaultCharactersRepository(remote: remote, pageSize: 10)

        let missingID = 99
        let dto = CharacterDTODummy.make(id: missingID, name: "Remote \(missingID)")
        await remote.succeedFetchCharacter(id: missingID, dto: dto)

        // When
        let first = try await repository.fetchCharacter(id: missingID)
        let second = try await repository.fetchCharacter(id: missingID)

        // Then
        #expect(first.id == missingID)
        #expect(second.id == missingID)

        let detailCalls = await remote.fetchCharacterCallCount()
        #expect(detailCalls == 1)

        let ids = await remote.fetchedCharacterIDs()
        #expect(ids == [missingID])
    }
}
