//
//  AppBackgroundView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        Image("RickAndMortyLaunchScreen")
            .resizable()
            .scaledToFill()
            .opacity(0.8)
            .blur(radius: 2)
            .overlay(.black.opacity(0.10)) 
            .ignoresSafeArea()
    }
}
