//
//  CharactersListView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharactersListView: View {
    @ObservedObject var viewModel: CharactersListViewModel
    let onSelectCharacter: (Int) -> Void

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
                let isLast = character.id == viewModel.state.characters.last?.id

                Button {
                    onSelectCharacter(character.id)
                } label: {
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            CharacterRowView(character: character)

                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                        if !isLast {
                            Divider()
                                .overlay(Color.primary.opacity(0.14))
                                .padding(.leading, 80)
                                .padding(.trailing, 12)
                        }
                    }
                    .background(.background.opacity(0.95)) // card opaca
                    .padding(.horizontal, 16)              // aquí se ven los laterales
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .onAppear { Task { await viewModel.loadMoreIfNeeded(currentItem: character) } }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)           // clave: deja ver el fondo por los lados
            }

            if viewModel.state.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)

        // Fondo “global” de pantalla
        .scrollContentBackground(.hidden)
        .background(AppBackgroundView())

        // Large title normal cuando NO estás en búsqueda
        .navigationTitle(isFilteredMode ? "" : "Characters")
        .navigationBarTitleDisplayMode(.large)

        .searchable(
            text: $viewModel.query,
            isPresented: $isSearchPresented,
            prompt: "Filter by name"
        )
        .onChange(of: viewModel.query) { _, _ in
            viewModel.onQueryChanged(viewModel.query)
        }
        .overlay {
            if viewModel.state.isLoading && viewModel.state.characters.isEmpty {
                ProgressView()
            }
        }
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
                .overlay(Divider(), alignment: .bottom)
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
