//
//  CharactersRepositoryMock.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

actor CharactersRepositoryMock: CharactersRepository {

    // MARK: - Detail

    private var fetchCharacterResults: [Result<RMCharacter, Error>] = []
    private var fetchCharacterCalls: [Int] = []

    // MARK: - List (not used in these tests, but required by protocol)

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> ([RMCharacter], RMPageInfo) {
        ([], RMPageInfo(nextPage: nil))
    }

    // MARK: - Protocol

    func fetchCharacter(id: Int) async throws -> RMCharacter {
        fetchCharacterCalls.append(id)

        guard !fetchCharacterResults.isEmpty else {
            preconditionFailure("CharactersRepositoryMock: no configured result for fetchCharacter(id:).")
        }

        let next = fetchCharacterResults.removeFirst()
        switch next {
        case .success(let character):
            return character
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Helpers (fluent API)

    @discardableResult
    func succeedOnce(with character: RMCharacter) async -> CharactersRepositoryMock {
        fetchCharacterResults.append(.success(character))
        return self
    }

    @discardableResult
    func failOnce(with error: Error) async -> CharactersRepositoryMock {
        fetchCharacterResults.append(.failure(error))
        return self
    }

    @discardableResult
    func succeed(times: Int, with character: RMCharacter) async -> CharactersRepositoryMock {
        guard times > 0 else { return self }
        for _ in 0..<times { fetchCharacterResults.append(.success(character)) }
        return self
    }

    @discardableResult
    func fail(times: Int, with error: Error) async -> CharactersRepositoryMock {
        guard times > 0 else { return self }
        for _ in 0..<times { fetchCharacterResults.append(.failure(error)) }
        return self
    }

    // MARK: - Introspection

    func fetchCharacterCallCount() -> Int {
        fetchCharacterCalls.count
    }

    func fetchedCharacterIDs() -> [Int] {
        fetchCharacterCalls
    }
}
