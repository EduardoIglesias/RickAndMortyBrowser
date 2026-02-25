//
//  CharacterDetailView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @ObservedObject var viewModel: CharacterDetailViewModel

    @State private var isLandscape = false

    var body: some View {
        GeometryReader { proxy in
            Group {
                if viewModel.state.isLoading && viewModel.state.character == nil {
                    ProgressView()
                } else if let message = viewModel.state.errorMessage {
                    CharacterDetailErrorView(message: message) {
                        Task { await viewModel.reload() }
                    }
                } else if let character = viewModel.state.character {
                    if isLandscape {
                        CharacterDetailLandscapeSplitView(character: character)
                    } else {
                        CharacterDetailPortraitListView(character: character)
                    }
                } else {
                    Text("No data.")
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear { updateOrientation(using: proxy.size) }
            .onChange(of: proxy.size) { _, newSize in
                updateOrientation(using: newSize)
            }
        }
        .navigationTitle("Character")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func updateOrientation(using size: CGSize) {
        let newValue = size.width > size.height
        if isLandscape != newValue {
            isLandscape = newValue
        }
    }
}

// MARK: - Portrait (List + banner + animación)

private struct CharacterDetailPortraitListView: View {
    let character: RMCharacter
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView(opacity: 0.18)

            List {
                CharacterDetailUI.headerBanner(character: character, height: 280)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                Section {
                    CharacterDetailUI.overviewCard(for: character)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Overview")
                        .font(.headline)
                        .textCase(nil)
                }

                Section {
                    CharacterDetailUI.locationsCard(for: character)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Locations")
                        .font(.headline)
                        .textCase(nil)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            // animación solo en portrait (tu “entrada”)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.96, anchor: .top)
            .onAppear {
                appeared = false
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.45)) { appeared = true }
                }
            }
        }
    }
}

// MARK: - Landscape (Split: izquierda imagen+nombre, derecha cards)

private struct CharacterDetailLandscapeSplitView: View {
    let character: RMCharacter

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppBackgroundView(opacity: 0.14)

            GeometryReader { proxy in
                let leftWidth = min(240, max(180, proxy.size.width * 0.30))

                ScrollView {
                    HStack(alignment: .top, spacing: 16) {
                        leftColumn(width: leftWidth)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.headline)

                            CharacterDetailUI.overviewCard(for: character)

                            Text("Locations")
                                .font(.headline)

                            CharacterDetailUI.locationsCard(for: character)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                // fuerza alineación arriba del scroll
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            }
        }
    }

    private func leftColumn(width: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 10) {
            RemoteImageView(url: character.imageURL, retries: 2) {
                CharacterDetailUI.placeholderHeader
            }
            .scaledToFill()
            .frame(width: width, height: width)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.quaternary, lineWidth: 1)
            )

            Text(character.name)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: width)
        }
        .frame(width: width, alignment: .top)
    }
}

// MARK: - Error

private struct CharacterDetailErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .foregroundStyle(.red)
                .font(.footnote)
                .multilineTextAlignment(.center)

            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Shared UI (banner + cards + pills)

private enum CharacterDetailUI {
    static func headerBanner(character: RMCharacter, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImageView(url: character.imageURL, retries: 2) {
                placeholderHeader
            }
            .scaledToFill()
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(character.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("characterDetail.name")

                HStack(spacing: 10) {
                    statusPill(text: character.status, color: statusColor(for: character.status))
                    pill(text: character.species)
                    pill(text: character.gender)
                }
            }
            .padding(16)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
    }

    static var placeholderHeader: some View {
        ZStack {
            Rectangle().fill(.quaternary)
            Image(systemName: "person.crop.square")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
        }
    }

    static func overviewCard(for character: RMCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            labeledRow(title: "Status", value: character.status, leadingDotColor: statusColor(for: character.status))
            Divider().opacity(0.5)
            labeledRow(title: "Species", value: character.species)
            Divider().opacity(0.5)
            labeledRow(title: "Gender", value: character.gender)
        }
        .cardStyle()
    }

    static func locationsCard(for character: RMCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            labeledRow(title: "Current location", value: character.locationName)
            Divider().opacity(0.5)
            labeledRow(title: "Origin", value: character.originName)
        }
        .cardStyle()
    }

    static func labeledRow(title: String, value: String, leadingDotColor: Color? = nil) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Group {
                if let leadingDotColor {
                    Circle().fill(leadingDotColor).frame(width: 10, height: 10)
                } else {
                    Color.clear.frame(width: 10, height: 10)
                }
            }
            .frame(width: 14, alignment: .center)
            .accessibilityHidden(true)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(minWidth: 90, idealWidth: 120, maxWidth: 140, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .layoutPriority(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    static func pill(text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.20))
            .clipShape(Capsule())
    }

    static func statusPill(text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8).accessibilityHidden(true)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.25))
        .clipShape(Capsule())
    }

    static func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}

// MARK: - Local card style (file-private)

private extension View {
    func cardStyle() -> some View {
        self
            .padding(14)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.quaternary, lineWidth: 1)
            )
    }
}
