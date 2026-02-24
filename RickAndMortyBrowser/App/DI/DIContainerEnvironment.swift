//
//  DIContainerEnvironment.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue = AppDIContainer()
}

extension EnvironmentValues {
    var diContainer: AppDIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
