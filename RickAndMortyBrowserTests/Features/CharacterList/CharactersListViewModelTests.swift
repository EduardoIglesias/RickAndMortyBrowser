//
//  CharactersListViewModelTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Testing
@testable import RickAndMortyBrowser

@Suite("CharactersListViewModel")
struct CharactersListViewModelTests {

    @Test @MainActor
    func loadInitialIfNeeded_loadsOnce() async {
        let repo = CharactersRepositoryListMock()
        await repo.succeed(page: 1, filter: nil, items: Self.makeCharacters(ids: 1...10), nextPage: 2)

        let sut = CharactersListViewModel(fetchCharactersPageUseCase: FetchCharactersPageUseCase(repository: repo))

        await sut.loadInitialIfNeeded()
        await sut.loadInitialIfNeeded()

        #expect(sut.state.characters.map(\.id) == Array(1...10))
        let calls = await repo.callCount()
        #expect(calls == 1)
    }

    @Test @MainActor
    func loadMoreIfNeeded_onlyLoadsWhenLastItemAppears() async {
        let repo = CharactersRepositoryListMock()
        await repo.succeed(page: 1, filter: nil, items: Self.makeCharacters(ids: 1...10), nextPage: 2)
        await repo.succeed(page: 2, filter: nil, items: Self.makeCharacters(ids: 11...20), nextPage: nil)

        let sut = CharactersListViewModel(fetchCharactersPageUseCase: FetchCharactersPageUseCase(repository: repo))

        await sut.loadInitialIfNeeded()
        #expect(sut.state.characters.count == 10)

        // Not last -> no load
        if let first = sut.state.characters.first {
            await sut.loadMoreIfNeeded(currentItem: first)
        }
        var calls = await repo.callCount()
        #expect(calls == 1)

        // Last -> load more
        if let last = sut.state.characters.last {
            await sut.loadMoreIfNeeded(currentItem: last)
        }

        #expect(sut.state.characters.map(\.id) == Array(1...20))
        calls = await repo.callCount()
        #expect(calls == 2)
        #expect(sut.state.canLoadMore == false)
    }

    @Test @MainActor
    func reload_usesQueryAsFilter() async {
        let repo = CharactersRepositoryListMock()
        await repo.succeed(page: 1, filter: "Rick", items: Self.makeCharacters(ids: 101...110), nextPage: nil)

        let sut = CharactersListViewModel(fetchCharactersPageUseCase: FetchCharactersPageUseCase(repository: repo))
        sut.query = "Rick"

        await sut.reload()

        #expect(sut.state.characters.map(\.id) == Array(101...110))
        let received = await repo.receivedCalls()
        #expect(received.count == 1)
        #expect(received.first?.filter == "Rick")
    }

    @Test @MainActor
    func loadInitialIfNeeded_whenRepositoryThrows_setsErrorAndStopsLoadingMore() async {
        let repo = CharactersRepositoryListMock()
        await repo.fail(page: 1, filter: nil, error: NetworkErrorDummy.http500())

        let sut = CharactersListViewModel(fetchCharactersPageUseCase: FetchCharactersPageUseCase(repository: repo))

        await sut.loadInitialIfNeeded()

        #expect(sut.state.characters.isEmpty)
        #expect(sut.state.errorMessage != nil)
        #expect(sut.state.canLoadMore == false)
    }

    @Test @MainActor
    func onQueryChanged_debouncesAndTriggersReload() async {
        let repo = CharactersRepositoryListMock()
        await repo.succeed(page: 1, filter: "Morty", items: Self.makeCharacters(ids: 201...210), nextPage: nil)

        let sut = CharactersListViewModel(fetchCharactersPageUseCase: FetchCharactersPageUseCase(repository: repo))
        sut.query = "Morty"
        sut.onQueryChanged("Morty")

        // Debounce = 300ms en tu VM
        try? await Task.sleep(for: .milliseconds(350))

        #expect(sut.state.characters.map(\.id) == Array(201...210))
        let calls = await repo.callCount()
        #expect(calls == 1)
    }

    private static func makeCharacters(ids: ClosedRange<Int>) -> [RMCharacter] {
        ids.map { RMCharacterDummy.make(id: $0) }
    }
}
