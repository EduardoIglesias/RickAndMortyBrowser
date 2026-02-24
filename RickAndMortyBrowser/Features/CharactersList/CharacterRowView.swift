//
//  CharacterRowView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharacterRowView: View {
    let character: RMCharacter

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .accessibilityIdentifier("characterRow.name")

                HStack(spacing: 8) {
                    statusDot
                    Text(character.status)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("characterRow.status")

                    Text("•")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)

                    Text(character.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private var avatar: some View {
        RemoteImageView(url: character.imageURL, retries: 2) {
            placeholderAvatar
        }
        .scaledToFill()
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
        .accessibilityElement()
        .accessibilityIdentifier("characterRow.avatar")
        .accessibilityLabel(Text("\(character.name) avatar"))
    }

    private var placeholderAvatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
            Image(systemName: "person.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var statusDot: some View {
        Circle()
            .frame(width: 8, height: 8)
            .foregroundStyle(statusColor)
            .accessibilityHidden(true)
    }

    private var statusColor: Color {
        switch character.status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}
