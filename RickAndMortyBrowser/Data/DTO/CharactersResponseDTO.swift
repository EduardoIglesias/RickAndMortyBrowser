//
//  CharactersResponseDTO.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct CharactersResponseDTO: Decodable, Sendable {
    let info: InfoDTO
    let results: [CharacterDTO]
}

struct InfoDTO: Decodable, Sendable {
    let next: String?
}
