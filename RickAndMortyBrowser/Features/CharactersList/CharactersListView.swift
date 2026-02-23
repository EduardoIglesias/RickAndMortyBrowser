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
            if let message = viewModel.state.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
            }

            ForEach(viewModel.state.characters) { character in
                NavigationLink {
                    CharacterDetailView(characterName: character.name)
                } label: {
                    CharacterRowView(character: character)
                }
                .onAppear {
                    Task {
                        await viewModel.loadMoreIfNeeded(currentItem: character)
                    }
                }
            }

            if viewModel.state.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .navigationTitle("Characters")
        .searchable(text: $viewModel.query, prompt: "Filter by name")
        .onChange(of: viewModel.query) { _, newValue in
            viewModel.onQueryChanged(newValue)
        }
        .overlay {
            if viewModel.state.isLoading && viewModel.state.characters.isEmpty {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadInitialIfNeeded()
        }
    }
}

