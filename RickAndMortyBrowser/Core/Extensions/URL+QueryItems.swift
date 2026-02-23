//
//  URL+QueryItems.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard !queryItems.isEmpty else { return self }
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        return components?.url ?? self
    }
}
