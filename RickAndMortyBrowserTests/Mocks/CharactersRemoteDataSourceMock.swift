//
//  CharactersRemoteDataSourceMock.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

actor CharactersRemoteDataSourceMock: CharactersRemoteDataSource {

    enum FilterKey: Hashable {
        case none
        case value(String)
    }

    struct FetchCharactersKey: Hashable {
        let page: Int
        let filter: FilterKey
    }

    private var fetchCharactersResults: [FetchCharactersKey: Result<CharactersResponseDTO, Error>] = [:]
    private var fetchCharacterResults: [Int: Result<CharacterDTO, Error>] = [:]

    private var fetchCharactersCalls: [FetchCharactersKey] = []
    private var fetchCharacterCalls: [Int] = []

    // MARK: - Configure

    func succeedFetchCharacters(page: Int, nameFilter: String?, response: CharactersResponseDTO) {
        fetchCharactersResults[.init(page: page, filter: normalize(nameFilter))] = .success(response)
    }

    func failFetchCharacters(page: Int, nameFilter: String?, error: Error) {
        fetchCharactersResults[.init(page: page, filter: normalize(nameFilter))] = .failure(error)
    }

    func succeedFetchCharacter(id: Int, dto: CharacterDTO) {
        fetchCharacterResults[id] = .success(dto)
    }

    func failFetchCharacter(id: Int, error: Error) {
        fetchCharacterResults[id] = .failure(error)
    }

    // MARK: - Protocol

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> CharactersResponseDTO {
        let key = FetchCharactersKey(page: page, filter: normalize(nameFilter))
        fetchCharactersCalls.append(key)

        guard let result = fetchCharactersResults[key] else {
            preconditionFailure("CharactersRemoteDataSourceMock: no configured result for fetchCharacters(page:\(page), nameFilter:\(String(describing: nameFilter))).")
        }

        switch result {
        case .success(let dto): return dto
        case .failure(let error): throw error
        }
    }

    func fetchCharacter(id: Int) async throws -> CharacterDTO {
        fetchCharacterCalls.append(id)

        guard let result = fetchCharacterResults[id] else {
            preconditionFailure("CharactersRemoteDataSourceMock: no configured result for fetchCharacter(id:\(id)).")
        }

        switch result {
        case .success(let dto): return dto
        case .failure(let error): throw error
        }
    }

    // MARK: - Introspection

    func fetchCharactersCallCount() -> Int { fetchCharactersCalls.count }
    func fetchCharacterCallCount() -> Int { fetchCharacterCalls.count }

    func fetchedCharacterIDs() -> [Int] { fetchCharacterCalls }

    // MARK: - Helpers

    private func normalize(_ filter: String?) -> FilterKey {
        let trimmed = (filter ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? .none : .value(trimmed)
    }
}
