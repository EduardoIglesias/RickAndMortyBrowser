//
//  RMCharacterDummy.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

enum RMCharacterDummy {
    static func make(id: Int = 1) -> RMCharacter {
        RMCharacter(
            id: id,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            gender: "Male",
            imageURL: nil,
            originName: "Earth (C-137)",
            locationName: "Citadel of Ricks"
        )
    }
}
