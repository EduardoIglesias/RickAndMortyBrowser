//
//  CharactersListView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharactersListView: View {
    @ObservedObject var viewModel: CharactersListViewModel
    @Environment(\.diContainer) private var diContainer

    @State private var isSearchPresented = false

    private var isFilteredMode: Bool {
        isSearchPresented ||
        !viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        List {
            if let message = viewModel.state.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
            }

            if isFilteredMode,
               !viewModel.state.isLoading,
               viewModel.state.errorMessage == nil,
               viewModel.state.characters.isEmpty {

                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No results in this dimension 👽")
                        .font(.headline)

                    Text("Try another name… or blame the Council of Ricks.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .listRowSeparator(.hidden)
            }

            ForEach(viewModel.state.characters) { character in
                NavigationLink(value: AppRoute.characterDetail(character.id)) {
                    CharacterRowView(character: character)
                        .frame(maxWidth: .infinity, alignment: .leading) // hace que el label ocupe toda la fila
                        .contentShape(Rectangle())                       // toda la fila es tappable
                }
                .buttonStyle(PressableRowStyle())
                .transaction { t in
                    t.animation = .smooth(duration: 0.25)
                }
                .onAppear {
                    Task { await viewModel.loadMoreIfNeeded(currentItem: character) }
                }
            }

            if viewModel.state.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .transition(.opacity)
                    Spacer()
                }
            }
        }
        // Large title normal cuando NO estás en búsqueda
        .navigationTitle(isFilteredMode ? "" : "Characters")
        .navigationBarTitleDisplayMode(.large)

        // Detecta foco real del buscador
        .searchable(
            text: $viewModel.query,
            isPresented: $isSearchPresented,
            prompt: "Filter by name"
        )
        .onChange(of: viewModel.query) { _, newValue in
            viewModel.onQueryChanged(newValue)
        }
        .overlay {
            if viewModel.state.isLoading && viewModel.state.characters.isEmpty {
                ProgressView()
                    .transition(.opacity)
            }
        }

        // Cabecera “custom” SOLO durante búsqueda
        .safeAreaInset(edge: .top, spacing: 0) {
            if isFilteredMode {
                HStack {
                    Text("Filtered Characters")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.background)
                .overlay(
                    Divider(),
                    alignment: .bottom
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.18), value: isFilteredMode)
        .animation(.smooth(duration: 0.2), value: viewModel.state.characters.count)
        .animation(.smooth(duration: 0.2), value: viewModel.state.isLoading)
        .animation(.smooth(duration: 0.2), value: viewModel.state.errorMessage)

        .task { await viewModel.loadInitialIfNeeded() }
    }
}
