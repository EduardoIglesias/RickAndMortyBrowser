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

    private var showFilteredEmptyState: Bool {
        isFilteredMode &&
        !viewModel.state.isLoading &&
        viewModel.state.errorMessage == nil &&
        viewModel.state.characters.isEmpty
    }

    var body: some View {
        List {
            if let message = viewModel.state.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            let characters = viewModel.state.characters

            ForEach(Array(characters.enumerated()), id: \.element.id) { index, character in
                CharacterCardRow(
                    character: character,
                    isFirst: index == 0,
                    isLast: index == characters.count - 1,
                    onTap: { onSelectCharacter(character.id) }
                )
                .onAppear {
                    Task { await viewModel.loadMoreIfNeeded(currentItem: character) }
                }
            }

            if viewModel.state.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 12)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppBackgroundView(opacity: 0.80))

        // Localizado (usamos String(localized:) para evitar mezclar tipos en el ternario)
        .navigationTitle(isFilteredMode ? "" : String(localized: "characters.title"))
        .navigationBarTitleDisplayMode(.large)

        .searchable(
            text: $viewModel.query,
            isPresented: $isSearchPresented,
            prompt: Text("characters.search.prompt")
        )
        .onChange(of: viewModel.query) { _, _ in
            viewModel.onQueryChanged(viewModel.query)
        }

        .safeAreaInset(edge: .top, spacing: 0) {
            if isFilteredMode {
                HStack {
                    Text("characters.filtered.title")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .opacity(0.85)
                .overlay(
                    Divider().opacity(0.6),
                    alignment: .bottom
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }

        .overlay {
            ZStack {
                if viewModel.state.isLoading && viewModel.state.characters.isEmpty {
                    ProgressView()
                }

                if showFilteredEmptyState {
                    FilteredEmptyStateCard()
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
        }

        .animation(.smooth(duration: 0.18), value: isFilteredMode)
        .animation(.smooth(duration: 0.2), value: showFilteredEmptyState)

        .task { await viewModel.loadInitialIfNeeded() }
    }
}

// MARK: - Row (card con chevron + separador interno + esquinas solo arriba/abajo)

private struct CharacterCardRow: View {
    let character: RMCharacter
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void

    private let radius: CGFloat = 16

    var body: some View {
        Button(action: onTap) {
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
                        .overlay(Color.primary.opacity(0.22))
                        .padding(.leading, 80)
                        .padding(.trailing, 12)
                }
            }
            .background(.background.opacity(0.95))
            .clipShape(cardShape)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private var cardShape: some Shape {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: isFirst ? radius : 0,
                bottomLeading: isLast ? radius : 0,
                bottomTrailing: isLast ? radius : 0,
                topTrailing: isFirst ? radius : 0
            )
        )
    }
}

// MARK: - Empty state centrado y redondeado

private struct FilteredEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("characters.empty.title")
                .font(.headline)

            Text("characters.empty.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: 320)
        .background(.background.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.quaternary, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}
