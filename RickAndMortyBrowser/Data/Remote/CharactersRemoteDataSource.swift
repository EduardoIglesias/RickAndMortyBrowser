//
//  CharactersRemoteDataSource.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

protocol CharactersRemoteDataSource: Sendable {
    func fetchCharacters(page: Int, nameFilter: String?) async throws -> CharactersResponseDTO
    func fetchCharacter(id: Int) async throws -> CharacterDTO
}

struct DefaultCharactersRemoteDataSource: CharactersRemoteDataSource {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> CharactersResponseDTO {
        let endpoint = RickAndMortyAPI.characters(page: page, name: nameFilter)
        let dto: CharactersResponseDTO = try await client.request(endpoint)
        return dto
    }

    func fetchCharacter(id: Int) async throws -> CharacterDTO {
        let endpoint = RickAndMortyAPI.character(id: id)
        let dto: CharacterDTO = try await client.request(endpoint)
        return dto
    }
}


