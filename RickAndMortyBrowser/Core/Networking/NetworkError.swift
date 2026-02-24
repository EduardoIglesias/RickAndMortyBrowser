//
//  NetworkError.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case transportError(String)
    case invalidResponse
    case httpStatus(Int, Data?)
    case decodingFailed
}
