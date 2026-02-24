//
//  CharactersResponseDTODummy.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation
@testable import RickAndMortyBrowser

enum CharactersResponseDTODummy {
    static func make(
        results: [CharacterDTO],
        nextPage: Int? = nil,
        nameFilter: String? = nil
    ) -> CharactersResponseDTO {
        let next: String?
        if let nextPage {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "rickandmortyapi.com"
            components.path = "/api/character"
            var items = [URLQueryItem(name: "page", value: String(nextPage))]
            if let nameFilter, !nameFilter.isEmpty {
                items.append(URLQueryItem(name: "name", value: nameFilter))
            }
            components.queryItems = items
            next = components.url?.absoluteString
        } else {
            next = nil
        }

        return CharactersResponseDTO(
            info: InfoDTO(next: next),
            results: results
        )
    }
}
