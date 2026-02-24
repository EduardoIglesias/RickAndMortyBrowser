//
//  AppBackgroundView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import SwiftUI

struct AppBackgroundView: View {
    private let opacity: Double
    private let blur: CGFloat
    private let darkOverlayOpacity: Double

    init(
        opacity: Double = 0.18,
        blur: CGFloat = 2,
        darkOverlayOpacity: Double = 0.10
    ) {
        self.opacity = opacity
        self.blur = blur
        self.darkOverlayOpacity = darkOverlayOpacity
    }

    var body: some View {
        Image("RickAndMortyLaunchScreen")
            .resizable()
            .scaledToFill()
            .opacity(opacity)
            .blur(radius: blur)
            .overlay(.black.opacity(darkOverlayOpacity))
            .ignoresSafeArea()
    }
}
