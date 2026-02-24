//
//  CharacterMapper.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

enum CharacterMapper {
    static func map(_ dto: CharacterDTO) -> RMCharacter {
        RMCharacter(
            id: dto.id,
            name: dto.name,
            status: dto.status,
            species: dto.species,
            gender: dto.gender,
            imageURL: URL(string: dto.image),
            originName: dto.origin.name,
            locationName: dto.location.name
        )
    }

    static func nextPage(from nextURLString: String?) -> Int? {
        guard let nextURLString, let url = URL(string: nextURLString) else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let pageValue = components?.queryItems?.first(where: { $0.name == "page" })?.value
        guard let pageValue, let page = Int(pageValue) else { return nil }
        return page
    }
}
