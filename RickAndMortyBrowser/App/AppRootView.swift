//
//  AppRootView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var viewModel: CharactersListViewModel

    init(diContainer: AppDIContainer = AppDIContainer()) {
        _viewModel = StateObject(wrappedValue: diContainer.makeCharactersListViewModel())
    }

    var body: some View {
        NavigationStack {
            CharactersListView(viewModel: viewModel)
        }
    }
}

#Preview {
    AppRootView()
}
