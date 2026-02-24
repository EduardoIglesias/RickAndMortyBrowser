//
//  CharactersListViewModel.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
import Combine

@MainActor
final class CharactersListViewModel: ObservableObject {
    @Published private(set) var state: CharactersListState = CharactersListState()
    @Published var query: String = ""

    private let fetchCharactersPageUseCase: FetchCharactersPageUseCase
    private var nextPage: Int? = 1
    private var hasLoadedOnce: Bool = false
    private var searchTask: Task<Void, Never>?

    init(fetchCharactersPageUseCase: FetchCharactersPageUseCase) {
        self.fetchCharactersPageUseCase = fetchCharactersPageUseCase
    }

    func loadInitialIfNeeded() async {
        guard !hasLoadedOnce else { return }
        hasLoadedOnce = true
        await reload()
    }

    func onQueryChanged(_ newValue: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard let self, !Task.isCancelled else { return }
            await self.reload()
        }
    }

    func reload() async {
        nextPage = 1
        state.errorMessage = nil
        state.canLoadMore = true
        state.characters = []

        await loadNextPage(isLoadMore: false)
    }

    func loadMoreIfNeeded(currentItem: RMCharacter) async {
        guard currentItem.id == state.characters.last?.id else { return }
        await loadNextPage(isLoadMore: true)
    }

    private func loadNextPage(isLoadMore: Bool) async {
        guard let page = nextPage else { return }
        if state.isLoading || state.isLoadingMore { return }

        if isLoadMore {
            state.isLoadingMore = true
        } else {
            state.isLoading = true
        }

        defer {
            state.isLoading = false
            state.isLoadingMore = false
        }

        do {
            let filter = normalizedQuery(from: query)
            let (items, info) = try await fetchCharactersPageUseCase.execute(page: page, nameFilter: filter)

            if isLoadMore {
                // Dedup por id para evitar duplicados (y warnings con matchedGeometry)
                let existingIDs = Set(state.characters.map(\.id))
                let newItems = items.filter { !existingIDs.contains($0.id) }

                state.characters.append(contentsOf: newItems)
                await ImagePipeline.shared.prefetch(newItems.compactMap(\.imageURL), retries: 1)
            } else {
                // Por seguridad: dedup también en la primera carga
                state.characters = Self.dedupByID(items)
                await ImagePipeline.shared.prefetch(state.characters.compactMap(\.imageURL), retries: 1)
            }

            nextPage = info.nextPage
            state.canLoadMore = (info.nextPage != nil)
        } catch {
            state.errorMessage = "Failed to load characters."
            nextPage = nil
            state.canLoadMore = false
        }
    }

    private func normalizedQuery(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func dedupByID(_ items: [RMCharacter]) -> [RMCharacter] {
        var seen = Set<Int>()
        return items.filter { seen.insert($0.id).inserted }
    }
}
