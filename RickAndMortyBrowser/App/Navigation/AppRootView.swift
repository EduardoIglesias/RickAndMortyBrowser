//
//  AppRootView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct AppRootView: View {
    private let diContainer: AppDIContainer
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
    }
    @StateObject private var listViewModel: CharactersListViewModel

    @State private var path = NavigationPath()

    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
        _listViewModel = StateObject(wrappedValue: diContainer.makeCharactersListViewModel())
    }

    var body: some View {
        NavigationStack(path: $path) {
            CharactersListView(viewModel: listViewModel) { id in
                withAnimation(.smooth(duration: 0.25)) {
                    path.append(AppRoute.characterDetail(id))
                }
            }
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
