//
//  RMCharacter.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

struct RMCharacter: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let imageURL: URL?
    let originName: String
    let locationName: String
}
