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
        VStack(alignment: .leading, spacing: 4) {
            Text(character.name)
                .font(.headline)

            Text("\(character.status) • \(character.species)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
