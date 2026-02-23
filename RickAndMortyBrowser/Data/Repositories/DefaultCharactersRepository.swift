//
//  DefaultCharactersRepository.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

actor DefaultCharactersRepository: CharactersRepository {
    private let pageSize: Int
    private let allCharacters: [RMCharacter]

    init(pageSize: Int = 10, allCharacters: [RMCharacter] = DefaultCharactersRepository.makeStubCharacters()) {
        self.pageSize = pageSize
        self.allCharacters = allCharacters
    }

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> ([RMCharacter], RMPageInfo) {
        try await Task.sleep(for: .milliseconds(120))

        let filtered = filterCharacters(allCharacters, by: nameFilter)

        let startIndex = max(0, (page - 1) * pageSize)
        guard startIndex < filtered.count else {
            return ([], RMPageInfo(nextPage: nil))
        }

        let endIndex = min(filtered.count, startIndex + pageSize)
        let slice = Array(filtered[startIndex..<endIndex])

        let nextPage: Int?
        if endIndex < filtered.count {
            nextPage = page + 1
        } else {
            nextPage = nil
        }

        return (slice, RMPageInfo(nextPage: nextPage))
    }

    private func filterCharacters(_ characters: [RMCharacter], by nameFilter: String?) -> [RMCharacter] {
        guard let nameFilter, !nameFilter.isEmpty else { return characters }

        let query = nameFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return characters }

        return characters.filter { $0.name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    private static func makeStubCharacters() -> [RMCharacter] {
        let statuses = ["Alive", "Dead", "Unknown"]
        let species = ["Human", "Alien", "Robot"]
        let genders = ["Female", "Male", "Unknown"]
        let origins = ["Earth (C-137)", "Citadel of Ricks", "Unknown"]
        let locations = ["Earth", "Citadel", "Space", "Unknown"]

        return (1...60).map { index in
            RMCharacter(
                id: index,
                name: "Character \(index)",
                status: statuses[index % statuses.count],
                species: species[index % species.count],
                gender: genders[index % genders.count],
                imageURL: nil,
                originName: origins[index % origins.count],
                locationName: locations[index % locations.count]
            )
        }
    }
}
