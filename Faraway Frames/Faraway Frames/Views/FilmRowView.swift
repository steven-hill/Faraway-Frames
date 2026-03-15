//
//  FilmRowView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 15/03/2026.
//

import SwiftUI

struct FilmRowView: View {
    let film: Film
    let image: UIImage?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var imageScale: CGFloat = 1.0
    
    var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }
    
    var body: some View {
        if isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                poster
                Text(film.title)
                    .font(.body)
            }
        } else {
            HStack(spacing: 12) {
                poster
                Text(film.title)
                    .font(.body)
                Spacer()
            }
        }
    }
    
    private var poster: some View {
        let sourceImage: Image = {
            if let image = image {
                return Image(uiImage: image)
            } else {
                return Image(systemName: "photo")
            }
        }()
        return applyPosterStyle(to: sourceImage)
    }
    
    @ViewBuilder
    private func applyPosterStyle(to image: Image) -> some View {
        image
            .resizable()
            .frame(width: 60 * imageScale, height: 90 * imageScale)
            .cornerRadius(10 * imageScale)
    }
}

#Preview {
    let film = Film.sample
    FilmRowView(film: film, image: nil)
}
