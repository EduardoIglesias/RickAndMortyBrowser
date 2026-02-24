//
//  AppDIContainer.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

final class AppDIContainer {
    private let client: NetworkClient
    private let remote: CharactersRemoteDataSource
    private let repository: CharactersRepository

    init() {
        self.client = DefaultNetworkClient()
        self.remote = DefaultCharactersRemoteDataSource(client: client)
        self.repository = DefaultCharactersRepository(remote: remote)
    }

    func makeCharactersListViewModel() -> CharactersListViewModel {
        let useCase = FetchCharactersPageUseCase(repository: repository)
        return CharactersListViewModel(fetchCharactersPageUseCase: useCase)
    }

    func makeCharacterDetailViewModel(characterID: Int) -> CharacterDetailViewModel {
        let useCase = FetchCharacterDetailUseCase(repository: repository)
        return CharacterDetailViewModel(characterID: characterID, fetchCharacterDetailUseCase: useCase)
    }
}
