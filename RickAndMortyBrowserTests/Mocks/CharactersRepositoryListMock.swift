//
//  CharactersRepositoryListMock.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

actor CharactersRepositoryListMock: CharactersRepository {

    struct Key: Hashable {
        let page: Int
        let filter: String?
    }

    private var results: [Key: Result<([RMCharacter], RMPageInfo), Error>] = [:]
    private var calls: [Key] = []

    func succeed(page: Int, filter: String?, items: [RMCharacter], nextPage: Int?) {
        results[Key(page: page, filter: normalize(filter))] = .success((items, RMPageInfo(nextPage: nextPage)))
    }

    func fail(page: Int, filter: String?, error: Error) {
        results[Key(page: page, filter: normalize(filter))] = .failure(error)
    }

    func fetchCharacters(page: Int, nameFilter: String?) async throws -> ([RMCharacter], RMPageInfo) {
        let key = Key(page: page, filter: normalize(nameFilter))
        calls.append(key)

        guard let result = results[key] else {
            throw TestDoubleError.notConfigured("fetchCharacters(page:\(page), filter:\(String(describing: nameFilter)))")
        }

        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }

    func fetchCharacter(id: Int) async throws -> RMCharacter {
        throw TestDoubleError.unexpectedCall("fetchCharacter(id:)")
    }

    func callCount() -> Int { calls.count }
    func receivedCalls() -> [Key] { calls }

    private func normalize(_ filter: String?) -> String? {
        let trimmed = (filter ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    enum TestDoubleError: Error, CustomStringConvertible {
        case unexpectedCall(String)
        case notConfigured(String)

        var description: String {
            switch self {
            case .unexpectedCall(let msg): return "Unexpected call: \(msg)"
            case .notConfigured(let msg): return "Not configured: \(msg)"
            }
        }
    }
}
