//
//  DefaultCharactersRepository.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

actor DefaultCharactersRepository: CharactersRepository {
    private let remote: CharactersRemoteDataSource
    private let pageSize: Int

    private var currentFilter: String?
    private var expectedUIPage: Int = 1

    private var buffer: [RMCharacter] = []
    private var nextRemotePage: Int? = 1

    init(
        remote: CharactersRemoteDataSource,
        pageSize: Int = 10
    ) {
        self.remote = remote
        self.pageSize = pageSize
    }

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> ([RMCharacter], RMPageInfo) {
        let normalized = normalize(nameFilter)

        if page == 1 || normalized != currentFilter || page != expectedUIPage {
            reset(for: normalized)
        }

        while buffer.count < pageSize, let remotePage = nextRemotePage {
            do {
                let dto = try await remote.fetchCharacters(page: remotePage, nameFilter: normalized)
                let mapped = dto.results.map(CharacterMapper.map)
                buffer.append(contentsOf: mapped)
                nextRemotePage = CharacterMapper.nextPage(from: dto.info.next)
            } catch let NetworkError.httpStatus(code, _) where code == 404 {
                // La API devuelve 404 cuando no hay resultados para el filtro.
                buffer = []
                nextRemotePage = nil
                break
            }
        }

        let count = min(pageSize, buffer.count)
        let items = Array(buffer.prefix(count))
        buffer.removeFirst(count)

        let hasMore = !buffer.isEmpty || nextRemotePage != nil
        let nextUIPage: Int? = hasMore ? (page + 1) : nil

        expectedUIPage = page + 1
        return (items, RMPageInfo(nextPage: nextUIPage))
    }

    private func reset(for filter: String?) {
        currentFilter = filter
        expectedUIPage = 1
        buffer = []
        nextRemotePage = 1
    }

    private func normalize(_ value: String?) -> String? {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
