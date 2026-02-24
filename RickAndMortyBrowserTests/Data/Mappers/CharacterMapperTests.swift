//
//  CharacterMapperTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("CharacterMapper")
struct CharacterMapperTests {

    @Test
    func map_mapsFieldsCorrectly() {
        let dto = CharacterDTODummy.make(
            id: 7,
            name: "Morty",
            status: "Alive",
            species: "Human",
            gender: "Male",
            image: "https://example.com/7.png",
            originName: "Earth",
            locationName: "Citadel"
        )

        let model = CharacterMapper.map(dto)

        #expect(model.id == 7)
        #expect(model.name == "Morty")
        #expect(model.status == "Alive")
        #expect(model.species == "Human")
        #expect(model.gender == "Male")
        #expect(model.imageURL?.absoluteString == "https://example.com/7.png")
        #expect(model.originName == "Earth")
        #expect(model.locationName == "Citadel")
    }

    @Test
    func nextPage_parsesPageFromNextURL() {
        let response = CharactersResponseDTODummy.make(
            results: [CharacterDTODummy.make(id: 1)],
            nextPage: 3
        )

        let next = CharacterMapper.nextPage(from: response.info.next)
        #expect(next == 3)
    }

    @Test
    func nextPage_nilWhenNextIsNilOrInvalid() {
        #expect(CharacterMapper.nextPage(from: nil) == nil)
        #expect(CharacterMapper.nextPage(from: "not a url") == nil)
    }
}
