//
//  DefaultCharactersRepositoryTests.swift
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

    @Test
    @MainActor
    func fetchCharacters_repeatedRemotePageAndFilter_usesCache_andDoesNotCallRemoteAgain() async throws {
        let remote = CharactersRemoteDataSourceMock()

        let page1Results = (1...20).map { CharacterDTODummy.make(id: $0, name: "Character \($0)") }
        let page1 = CharactersResponseDTODummy.make(results: page1Results, nextPage: nil)

        await remote.succeedFetchCharacters(page: 1, nameFilter: nil, response: page1)

        let repository = DefaultCharactersRepository(remote: remote, pageSize: 10)

        // First call: UI page 1 -> should fetch remote page 1
        let (first, _) = try await repository.fetchCharacters(page: 1, nameFilter: nil)
        #expect(first.map(\.id) == Array(1...10))
        #expect(await remote.fetchCharactersCallCount() == 1)

        // Second call: simulate a "restart" of the paging session (reload)
        // This triggers reset and would normally fetch remote page 1 again,
        // but page cache should serve it without another remote call.
        let (second, _) = try await repository.fetchCharacters(page: 1, nameFilter: nil)
        #expect(second.map(\.id) == Array(1...10))
        #expect(await remote.fetchCharactersCallCount() == 1) // still 1
    }

    @Test
    @MainActor
    func fetchCharacters_sameRemotePageDifferentFilter_doesCallRemoteAgain() async throws {
        let remote = CharactersRemoteDataSourceMock()

        let unfilteredResults = (1...20).map { CharacterDTODummy.make(id: $0, name: "Character \($0)") }
        let filteredResults = (101...120).map { CharacterDTODummy.make(id: $0, name: "Rick \($0)") }

        let unfiltered = CharactersResponseDTODummy.make(results: unfilteredResults, nextPage: nil)
        let filtered = CharactersResponseDTODummy.make(results: filteredResults, nextPage: nil, nameFilter: "Rick")

        await remote.succeedFetchCharacters(page: 1, nameFilter: nil, response: unfiltered)
        await remote.succeedFetchCharacters(page: 1, nameFilter: "Rick", response: filtered)

        let repository = DefaultCharactersRepository(remote: remote, pageSize: 10)

        _ = try await repository.fetchCharacters(page: 1, nameFilter: nil)
        #expect(await remote.fetchCharactersCallCount() == 1)

        _ = try await repository.fetchCharacters(page: 1, nameFilter: "Rick")
        #expect(await remote.fetchCharactersCallCount() == 2) // ifferent cache key
    }
}
