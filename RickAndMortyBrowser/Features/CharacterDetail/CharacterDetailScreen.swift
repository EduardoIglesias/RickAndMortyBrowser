//
//  CharacterDetailScreen.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharacterDetailScreen: View {
    private let characterID: Int
    private let diContainer: AppDIContainer

    @StateObject private var viewModel: CharacterDetailViewModel
    @State private var didHaptic = false

    init(characterID: Int, diContainer: AppDIContainer) {
        self.characterID = characterID
        self.diContainer = diContainer
        _viewModel = StateObject(
            wrappedValue: diContainer.makeCharacterDetailViewModel(characterID: characterID)
        )
    }

    var body: some View {
        CharacterDetailView(viewModel: viewModel, characterID: characterID)
            .task(id: characterID) {
                if !didHaptic {
                    didHaptic = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                await viewModel.loadIfNeeded()
            }
            .id(characterID) // fuerza identidad estable por id
    }
}
