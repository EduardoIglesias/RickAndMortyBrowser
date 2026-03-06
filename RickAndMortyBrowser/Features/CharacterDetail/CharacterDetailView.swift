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
                    DetailNoDataCard()
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .onAppear { updateOrientation(using: proxy.size) }
            .onChange(of: proxy.size) { _, newSize in
                updateOrientation(using: newSize)
            }
        }
        .navigationTitle("detail.title")
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
                    Text("detail.overview.title")
                        .font(.headline)
                        .textCase(nil)
                }

                Section {
                    CharacterDetailUI.locationsCard(for: character)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } header: {
                    Text("detail.locations.title")
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
                            Text("detail.overview.title")
                                .font(.headline)

                            CharacterDetailUI.overviewCard(for: character)

                            Text("detail.locations.title")
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
                .accessibilityIdentifier("characterDetail.name")
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

            Button("common.retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Shared UI (banner + cards + pills)

enum CharacterDetailUI {
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
                    .accessibilityElement(children: .contain)

                HStack(spacing: 10) {
                    statusPill(text: character.localizedStatus, color: statusColor(for: character.status))
                    pill(text: character.localizedSpecies)
                    pill(text: character.localizedGender)
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
            labeledRow(
                fieldID: "status",
                titleKey: "detail.field.status",
                value: character.localizedStatus,
                leadingDotColor: CharacterDetailUI.statusColor(for: character.status)
            )
            Divider().opacity(0.5)
            labeledRow(fieldID: "species", titleKey: "detail.field.species", value: character.localizedSpecies)
            Divider().opacity(0.5)
            labeledRow(fieldID: "gender", titleKey: "detail.field.gender", value: character.localizedGender)
        }
        .cardStyle()
    }

    static func locationsCard(for character: RMCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            labeledRow(
                fieldID: "currentlocation",
                titleKey: "detail.field.currentLocation",
                value: character.localizedLocationName
            )
            Divider().opacity(0.5)
            labeledRow(fieldID: "origin", titleKey: "detail.field.origin", value: character.localizedOriginName)
        }
        .cardStyle()
    }

    static private func labeledRow(
        fieldID: String,
        titleKey: LocalizedStringKey,
        value: String,
        leadingDotColor: Color? = nil
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Group {
                if let leadingDotColor {
                    Circle()
                        .fill(leadingDotColor)
                        .frame(width: 10, height: 10)
                } else {
                    Color.clear
                        .frame(width: 10, height: 10)
                }
            }
            .frame(width: 14, alignment: .center)
            .accessibilityHidden(true)

            Text(titleKey)
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
                // ID estable, independiente del idioma
                .accessibilityIdentifier("characterDetail.\(fieldID).value")
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

// MARK: - Empty state centrado y redondeado

private struct DetailNoDataCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.circle")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("detail.noData.title")
                .font(.headline)

            Text("detail.noData.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: 340)
        .background(.background.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.quaternary, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}
