//
//  CharacterDetailState.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct CharacterDetailState: Equatable {
    var isLoading: Bool = false
    var character: RMCharacter?
    var errorMessage: String?
}
