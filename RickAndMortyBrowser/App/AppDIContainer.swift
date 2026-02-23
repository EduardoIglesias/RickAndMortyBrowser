//
//  AppDIContainer.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

final class AppDIContainer {
    func makeCharactersListViewModel() -> CharactersListViewModel {
        let client = DefaultNetworkClient()
        let remote = DefaultCharactersRemoteDataSource(client: client)
        let repository: CharactersRepository = DefaultCharactersRepository(remote: remote)

        let useCase = FetchCharactersPageUseCase(repository: repository)
        return CharactersListViewModel(fetchCharactersPageUseCase: useCase)
    }
}
