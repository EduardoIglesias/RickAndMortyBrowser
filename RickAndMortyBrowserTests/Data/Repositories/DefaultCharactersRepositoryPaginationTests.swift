//
//  DefaultCharactersRepositoryPaginationTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Testing
@testable import RickAndMortyBrowser

@Suite("DefaultCharactersRepository - pagination & buffering")
struct DefaultCharactersRepositoryPaginationTests {

    @Test
    func fetchCharacters_returns10PerPage_buffers20FromRemote_andMinimizesRemoteCalls() async throws {
        // Given
        let remote = CharactersRemoteDataSourceMock()

        let page1Results = Self.makeDTOs(ids: 1...20)
        let page2Results = Self.makeDTOs(ids: 21...40)

        let page1 = CharactersResponseDTODummy.make(results: page1Results, nextPage: 2)
        let page2 = CharactersResponseDTODummy.make(results: page2Results, nextPage: nil)

        await remote.succeedFetchCharacters(page: 1, nameFilter: nil, response: page1)
        await remote.succeedFetchCharacters(page: 2, nameFilter: nil, response: page2)

        let repository = await MainActor.run {
            DefaultCharactersRepository(remote: remote, pageSize: 10)
        }

        // When / Then - UI page 1 -> consumes remote page 1 (20) but returns 10
        do {
            let (items, info) = try await repository.fetchCharacters(page: 1, nameFilter: nil)
            #expect(items.map(\.id) == Array(1...10))
            #expect(info.nextPage == 2)

            let remoteCalls = await remote.fetchCharactersCallCount()
            #expect(remoteCalls == 1)
        }

        // UI page 2 -> should come from buffer (no remote call)
        do {
            let (items, info) = try await repository.fetchCharacters(page: 2, nameFilter: nil)
            #expect(items.map(\.id) == Array(11...20))
            #expect(info.nextPage == 3)

            let remoteCalls = await remote.fetchCharactersCallCount()
            #expect(remoteCalls == 1) // still 1
        }

        // UI page 3 -> buffer empty, must fetch remote page 2, returns first 10
        do {
            let (items, info) = try await repository.fetchCharacters(page: 3, nameFilter: nil)
            #expect(items.map(\.id) == Array(21...30))
            #expect(info.nextPage == 4)

            let remoteCalls = await remote.fetchCharactersCallCount()
            #expect(remoteCalls == 2)
        }

        // UI page 4 -> remaining buffer, no remote call, end of data
        do {
            let (items, info) = try await repository.fetchCharacters(page: 4, nameFilter: nil)
            #expect(items.map(\.id) == Array(31...40))
            #expect(info.nextPage == nil)

            let remoteCalls = await remote.fetchCharactersCallCount()
            #expect(remoteCalls == 2)
        }
    }

    @Test
    func fetchCharacters_whenFilterChanges_resetsBuffer_andFetchesRemoteAgain() async throws {
        // Given
        let remote = CharactersRemoteDataSourceMock()

        let unfilteredResults = Self.makeDTOs(ids: 1...20)
        let filteredResults = Self.makeDTOs(ids: 101...120)

        let unfilteredPage1 = CharactersResponseDTODummy.make(results: unfilteredResults, nextPage: 2)
        let filteredPage1 = CharactersResponseDTODummy.make(results: filteredResults, nextPage: nil, nameFilter: "Rick")

        await remote.succeedFetchCharacters(page: 1, nameFilter: nil, response: unfilteredPage1)
        await remote.succeedFetchCharacters(page: 1, nameFilter: "Rick", response: filteredPage1)

        let repository = await MainActor.run {
            DefaultCharactersRepository(remote: remote, pageSize: 10)
        }

        // When: first load without filter
        do {
            let (items, info) = try await repository.fetchCharacters(page: 1, nameFilter: nil)
            #expect(items.map(\.id) == Array(1...10))
            #expect(info.nextPage == 2)

            let calls = await remote.fetchCharactersCallCount()
            #expect(calls == 1)
        }

        // Then: load page 1 with a different filter should reset and call remote again
        do {
            let (items, info) = try await repository.fetchCharacters(page: 1, nameFilter: "Rick")
            #expect(items.map(\.id) == Array(101...110))
            #expect(info.nextPage == 2) // because buffer still has 10 more (111...120)

            let calls = await remote.fetchCharactersCallCount()
            #expect(calls == 2)
        }
    }

    // MARK: - Helpers

    private static func makeDTOs(ids: ClosedRange<Int>) -> [CharacterDTO] {
        ids.map { id in
            CharacterDTODummy.make(id: id, name: "Character \(id)")
        }
    }
}
