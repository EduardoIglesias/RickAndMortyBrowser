//
//  RickAndMortyBrowserApp.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

@main
struct RickAndMortyBrowserApp: App {
    private let diContainer = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            AppRootView(diContainer: diContainer)
        }
    }
}
