//
//  CharacterDetailView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharacterDetailView: View {
    let characterName: String

    var body: some View {
        Text(characterName)
            .font(.title2)
            .navigationTitle("Detail")
    }
}

#Preview {
    NavigationStack { CharacterDetailView(characterName: "Rick Sanchez") }
}
