//
//  CharactersListView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharactersListView: View {
    @ObservedObject var viewModel: CharactersListViewModel

    var body: some View {
        List {
            ForEach(viewModel.state.characters) { character in
                NavigationLink(value: AppRoute.characterDetail(character.id)) {
                    CharacterRowView(character: character)
                }
                .onAppear {
                    Task { await viewModel.loadMoreIfNeeded(currentItem: character) }
                }
            }
        }
        .navigationTitle("Characters")
        .searchable(text: $viewModel.query, prompt: "Filter by name")
        .onChange(of: viewModel.query) { oldValue, newValue in
            guard oldValue != newValue else { return }
            viewModel.onQueryChanged(newValue)
        }
        .task { await viewModel.loadInitialIfNeeded() }
    }
}
