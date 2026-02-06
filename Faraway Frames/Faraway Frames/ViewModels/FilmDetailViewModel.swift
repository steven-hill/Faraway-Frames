//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation
import UIKit

final class FilmDetailViewModel {
    
    private let imageLoader: ImageLoader
    
    private(set) var currentState: FilmDetailState = .noFilmSelected {
        didSet {
            updateUI()
        }
    }
    weak var delegate: FilmDetailViewModelDelegate?
    
    enum FilmDetailState: Equatable {
        case noFilmSelected
        case content(Film)
    }
    
    init(film: Film? = nil, imageLoader: ImageLoader) {
        if let film {
            currentState = .content(film)
        }
        self.imageLoader = imageLoader
    }
    
    func setFilm(_ film: Film?) {
        if let film {
            currentState = .content(film)
        } else {
            currentState = .noFilmSelected
        }
    }
    
    func updateUI() {
        switch currentState {
        case .noFilmSelected:
            delegate?.didUpdateWithEmptyState()
        case .content(_):
            delegate?.didUpdateFilmDetails()
        }
    }
    
    func getMovieBanner(for film: Film) async -> UIImage? {
        guard let url = URL(string: film.movieBanner) else { return nil }
        let image = await imageLoader.loadImage(from: url)
        return image
    }
}
