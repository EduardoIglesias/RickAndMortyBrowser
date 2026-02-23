//
//  AppDIContainer.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

final class AppDIContainer {
    private let charactersRepository: CharactersRepository

    init(charactersRepository: CharactersRepository = DefaultCharactersRepository()) {
        self.charactersRepository = charactersRepository
    }

    func makeCharactersListViewModel() -> CharactersListViewModel {
        let useCase = FetchCharactersPageUseCase(repository: charactersRepository)
        return CharactersListViewModel(fetchCharactersPageUseCase: useCase)
    }
}
