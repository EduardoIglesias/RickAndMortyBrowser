//
//  CharacterDetailViewModel.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Combine
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var state: CharacterDetailState = CharacterDetailState()

    private let characterID: Int
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase
    private var hasLoaded: Bool = false

    init(characterID: Int, fetchCharacterDetailUseCase: FetchCharacterDetailUseCase) {
        self.characterID = characterID
        self.fetchCharacterDetailUseCase = fetchCharacterDetailUseCase
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await load()
    }

    func reload() async {
        hasLoaded = false
        await loadIfNeeded()
    }

    private func load() async {
        state.isLoading = true
        state.errorMessage = nil
        defer { state.isLoading = false }

        do {
            let character = try await fetchCharacterDetailUseCase.execute(id: characterID)
            state.character = character
        } catch {
            state.errorMessage = debugMessage(for: error)
        }
    }

    private func debugMessage(for error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                return "NetworkError.invalidURL"
            case .transportError(let message):
                return "NetworkError.transportError: \(message)"
            case .invalidResponse:
                return "NetworkError.invalidResponse"
            case .httpStatus(let code, let data):
                if let data, let body = String(data: data, encoding: .utf8) {
                    return "NetworkError.httpStatus(\(code)) body: \(body)"
                }
                return "NetworkError.httpStatus(\(code))"
            case .decodingFailed:
                return "NetworkError.decodingFailed"
            }
        }

        return "Error: \(String(describing: error))"
    }
}
