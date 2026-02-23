//
//  CharactersListView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharactersListView: View {
    var body: some View {
        List {
            NavigationLink("Rick Sanchez") {
                CharacterDetailView(characterName: "Rick Sanchez")
            }
            NavigationLink("Morty Smith") {
                CharacterDetailView(characterName: "Morty Smith")
            }
        }
        .navigationTitle("Characters")
    }
}

#Preview {
    NavigationStack { CharactersListView() }
}
