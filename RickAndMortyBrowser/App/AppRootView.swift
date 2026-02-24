//
//  AppRootView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct AppRootView: View {
    private let diContainer: AppDIContainer
    @StateObject private var listViewModel: CharactersListViewModel

    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
        _listViewModel = StateObject(wrappedValue: diContainer.makeCharactersListViewModel())
    }

    var body: some View {
        NavigationStack {
            CharactersListView(viewModel: listViewModel)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .characterDetail(let id):
                        CharacterDetailScreen(characterID: id, diContainer: diContainer)
                    }
                }
        }
        .environment(\.diContainer, diContainer)
    }
}
