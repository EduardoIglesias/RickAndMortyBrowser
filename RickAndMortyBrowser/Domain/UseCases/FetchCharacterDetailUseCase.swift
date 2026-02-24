//
//  FetchCharacterDetailUseCase.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct FetchCharacterDetailUseCase: Sendable {
    private let repository: CharactersRepository

    init(repository: CharactersRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> RMCharacter {
        try await repository.fetchCharacter(id: id)
    }
}
