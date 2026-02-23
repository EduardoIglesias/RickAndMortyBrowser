//
//  CharacterDTO.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct CharacterDTO: Decodable, Sendable {
    struct NamedRefDTO: Decodable, Sendable {
        let name: String
    }

    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let image: String
    let origin: NamedRefDTO
    let location: NamedRefDTO
}
