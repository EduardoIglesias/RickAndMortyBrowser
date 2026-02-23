//
//  CharactersRemoteDataSource.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

protocol CharactersRemoteDataSource: Sendable {
    func fetchCharacters(page: Int, nameFilter: String?) async throws -> CharactersResponseDTO
}

struct DefaultCharactersRemoteDataSource: CharactersRemoteDataSource {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> CharactersResponseDTO {
        let endpoint = RickAndMortyAPI.characters(page: page, name: nameFilter)
        return try await client.request(endpoint, as: CharactersResponseDTO.self)
    }
}
