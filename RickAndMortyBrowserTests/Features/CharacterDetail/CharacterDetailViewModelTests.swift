//
//  CharacterDetailViewModelTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Testing
@testable import RickAndMortyBrowser

@Suite("CharacterDetailViewModel")
struct CharacterDetailViewModelTests {

    @Test @MainActor
    func loadIfNeeded_success_setsCharacter_andClearsError() async {
        let repository = CharactersRepositoryMock()
        await repository.succeedOnce(with: RMCharacterDummy.make(id: 1))

        let useCase = FetchCharacterDetailUseCase(repository: repository)
        let sut = CharacterDetailViewModel(characterID: 1, fetchCharacterDetailUseCase: useCase)

        await sut.loadIfNeeded()

        #expect(sut.state.isLoading == false)
        #expect(sut.state.errorMessage == nil)
        #expect(sut.state.character?.id == 1)

        let callCount = await repository.fetchCharacterCallCount()
        #expect(callCount == 1)

        let ids = await repository.fetchedCharacterIDs()
        #expect(ids == [1])
    }

    @Test @MainActor
    func loadIfNeeded_error_setsErrorMessage_andKeepsCharacterNil() async {
        let repository = CharactersRepositoryMock()
        await repository.failOnce(with: NetworkErrorDummy.http404())

        let useCase = FetchCharacterDetailUseCase(repository: repository)
        let sut = CharacterDetailViewModel(characterID: 999_999, fetchCharacterDetailUseCase: useCase)

        await sut.loadIfNeeded()

        #expect(sut.state.isLoading == false)
        #expect(sut.state.character == nil)
        #expect(sut.state.errorMessage != nil)

        let callCount = await repository.fetchCharacterCallCount()
        #expect(callCount == 1)

        let ids = await repository.fetchedCharacterIDs()
        #expect(ids == [999_999])
    }

    @Test @MainActor
    func loadIfNeeded_calledTwice_fetchesOnlyOnce() async {
        let repository = CharactersRepositoryMock()
        await repository.succeedOnce(with: RMCharacterDummy.make(id: 1))

        let useCase = FetchCharacterDetailUseCase(repository: repository)
        let sut = CharacterDetailViewModel(characterID: 1, fetchCharacterDetailUseCase: useCase)

        await sut.loadIfNeeded()
        await sut.loadIfNeeded()

        let callCount = await repository.fetchCharacterCallCount()
        #expect(callCount == 1)

        let ids = await repository.fetchedCharacterIDs()
        #expect(ids == [1])
    }

    @Test @MainActor
    func reload_forcesSecondFetch() async {
        let repository = CharactersRepositoryMock()
        await repository.succeed(times: 2, with: RMCharacterDummy.make(id: 1))

        let useCase = FetchCharacterDetailUseCase(repository: repository)
        let sut = CharacterDetailViewModel(characterID: 1, fetchCharacterDetailUseCase: useCase)

        await sut.loadIfNeeded()
        await sut.reload()

        let callCount = await repository.fetchCharacterCallCount()
        #expect(callCount == 2)

        let ids = await repository.fetchedCharacterIDs()
        #expect(ids == [1, 1])
    }
}
