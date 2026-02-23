//
//  CharacterDetailView.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @ObservedObject var viewModel: CharacterDetailViewModel

    var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.character == nil {
                ProgressView()
            } else if let message = viewModel.state.errorMessage {
                VStack(spacing: 12) {
                    Text(message)
                        .foregroundStyle(.red)
                    Button("Retry") {
                        Task { await viewModel.reload() }
                    }
                }
            } else if let character = viewModel.state.character {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let url = character.imageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                case .failure:
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }

                        Text(character.name)
                            .font(.title2)
                            .bold()

                        Text("\(character.status) • \(character.species) • \(character.gender)")
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Origin: \(character.originName)")
                            Text("Location: \(character.locationName)")
                        }
                        .font(.body)
                    }
                    .padding()
                }
            } else {
                Text("No data.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Detail")
    }
}
