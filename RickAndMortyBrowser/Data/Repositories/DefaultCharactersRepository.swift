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

    private var characterCache: [Int: RMCharacter] = [:]

    // Cache de páginas remotas para reducir llamadas a la API
    private struct PageKey: Hashable {
        let remotePage: Int
        let filter: String?
    }

    private struct CachedPage {
        let dto: CharactersResponseDTO
        let timestamp: Date
    }

    private var pageCache: [PageKey: CachedPage] = [:]
    private let pageCacheTTL: TimeInterval = 10 * 60 // 10 minutos

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
                let key = PageKey(remotePage: remotePage, filter: normalized)

                let dto: CharactersResponseDTO
                if let cached = pageCache[key], Date().timeIntervalSince(cached.timestamp) < pageCacheTTL {
                    dto = cached.dto
                } else {
                    dto = try await remote.fetchCharacters(page: remotePage, nameFilter: normalized)
                    pageCache[key] = CachedPage(dto: dto, timestamp: Date())
                }

                let mapped: [RMCharacter] = await MainActor.run { dto.results.map { CharacterMapper.map($0) } }

                // Cachea también por ID para el detalle
                for item in mapped {
                    characterCache[item.id] = item
                }

                buffer.append(contentsOf: mapped)
                nextRemotePage = await MainActor.run { CharacterMapper.nextPage(from: dto.info.next) }

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

    func fetchCharacter(id: Int) async throws -> RMCharacter {
        if let cached = characterCache[id] { return cached }

        let dto = try await remote.fetchCharacter(id: id)
        let mapped: RMCharacter = await MainActor.run { CharacterMapper.map(dto) }
        characterCache[id] = mapped
        return mapped
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

