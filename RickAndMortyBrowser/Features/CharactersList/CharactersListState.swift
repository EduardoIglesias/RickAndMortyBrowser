//
//  CharactersListState.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct CharactersListState: Equatable {
    var characters: [RMCharacter] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var canLoadMore: Bool = true
    var errorMessage: String?
}
