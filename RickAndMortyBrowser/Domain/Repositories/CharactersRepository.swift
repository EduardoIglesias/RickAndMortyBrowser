//
//  CharactersRepository.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

protocol CharactersRepository: Sendable {
    func fetchCharacters(page: Int, nameFilter: String?) async throws -> ([RMCharacter], RMPageInfo)

    func fetchCharacter(id: Int) async throws -> RMCharacter
}
