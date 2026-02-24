//
//  CharacterDetailView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @ObservedObject var viewModel: CharacterDetailViewModel

    var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.character == nil {
                ProgressView()
            } else if let message = viewModel.state.errorMessage {
                VStack(spacing: 12) {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        Task { await viewModel.reload() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let character = viewModel.state.character {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header(for: character)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.headline)

                            overviewCard(for: character)

                            Text("Locations")
                                .font(.headline)

                            locationsCard(for: character)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.smooth(duration: 0.25), value: viewModel.state.character?.id)
                }
            } else {
                Text("No data.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Character")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    @ViewBuilder
    private func header(for character: RMCharacter) -> some View {
        ZStack(alignment: .bottomLeading) {
            headerImage(for: character)

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
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func headerImage(for character: RMCharacter) -> some View {
        RemoteImageView(url: character.imageURL, retries: 2) {
            placeholderHeader
        }
        .scaledToFill()
        .clipped()
    }

    private var placeholderHeader: some View {
        ZStack {
            Rectangle().fill(.quaternary)
            Image(systemName: "person.crop.square")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Cards

    private func overviewCard(for character: RMCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            labeledRow(title: "Status", value: character.status, leadingDotColor: statusColor(for: character.status))
            Divider().opacity(0.5)
            labeledRow(title: "Species", value: character.species)
            Divider().opacity(0.5)
            labeledRow(title: "Gender", value: character.gender)
        }
        .cardStyle()
    }

    private func locationsCard(for character: RMCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            labeledRow(title: "Current location", value: character.locationName)
            Divider().opacity(0.5)
            labeledRow(title: "Origin", value: character.originName)
        }
        .cardStyle()
    }

    private func labeledRow(title: String, value: String, leadingDotColor: Color? = nil) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            // Fixed leading slot for alignment across rows
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

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                // not fixed; keeps things left-aligned and SE-friendly
                .frame(minWidth: 90, idealWidth: 120, maxWidth: 140, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .layoutPriority(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("characterDetail.\(title.replacingOccurrences(of: " ", with: "").lowercased()).value")
        }
    }

    // MARK: - Pills

    private func pill(text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.20))
            .clipShape(Capsule())
    }

    private func statusPill(text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

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

    // MARK: - Status color

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Card style

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
