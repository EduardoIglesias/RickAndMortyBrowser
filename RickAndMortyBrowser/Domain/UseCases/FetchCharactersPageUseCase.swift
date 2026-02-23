//
//  FetchCharactersPageUseCase.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct FetchCharactersPageUseCase: Sendable {
    private let repository: CharactersRepository

    init(repository: CharactersRepository) {
        self.repository = repository
    }

    func execute(page: Int, nameFilter: String?) async throws -> ([RMCharacter], RMPageInfo) {
        try await repository.fetchCharacters(page: page, nameFilter: nameFilter)
    }
}
