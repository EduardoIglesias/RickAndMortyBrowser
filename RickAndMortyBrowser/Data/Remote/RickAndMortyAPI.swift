//
//  RickAndMortyAPI.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

enum RickAndMortyAPI {
    static let baseURL: URL = {
        guard let url = URL(string: "https://rickandmortyapi.com/api") else {
            preconditionFailure("Invalid base URL for RickAndMortyAPI")
        }
        return url
    }()

    static func characters(page: Int, name: String?) -> Endpoint {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page))
        ]
        if let name, !name.isEmpty {
            items.append(URLQueryItem(name: "name", value: name))
        }

        return Endpoint(baseURL: baseURL, path: "character", queryItems: items)
    }
}
