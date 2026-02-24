//
//  URL+QueryItems.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

extension URL {
    func appendingQueryItems(_ items: [URLQueryItem]) -> URL {
        guard !items.isEmpty else { return self }
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = items
        return components?.url ?? self
    }
}
