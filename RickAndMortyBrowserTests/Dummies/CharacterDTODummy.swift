//
//  CharacterDTODummy.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

enum CharacterDTODummy {
    static func make(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        gender: String = "Male",
        image: String = "https://example.com/1.png",
        originName: String = "Earth (C-137)",
        locationName: String = "Citadel of Ricks"
    ) -> CharacterDTO {
        CharacterDTO(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            image: image,
            origin: .init(name: originName),
            location: .init(name: locationName)
        )
    }
}
