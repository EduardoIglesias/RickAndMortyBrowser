//
//  AppRootView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct AppRootView: View {
    var body: some View {
        NavigationStack {
            CharactersListView()
        }
    }
}

#Preview {
    AppRootView()
}
