//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation
import UIKit

final class FilmDetailViewModel {
    
    // MARK: - State Definition
    enum FilmDetailState: Equatable {
        case noFilmSelected
        case content(displayModel: FilmDetailDisplayModel, image: UIImage? = nil)
    }
    
    // MARK: - Properties
    private let imageLoader: ImageLoader
    private(set) var imageLoadTask: Task<Void, Never>?
    private(set) var currentState: FilmDetailState = .noFilmSelected {
        didSet {
            updateUI()
        }
    }
    weak var delegate: FilmDetailViewModelDelegate?
    
    // MARK: - Initialisation
    init(film: Film? = nil, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        if let film {
            setFilm(film)
        }
    }
    
    // MARK: - Methods
    func setFilm(_ film: Film?) {
        imageLoadTask?.cancel()
        
        guard let film = film else {
            currentState = .noFilmSelected
            return
        }
        currentState = .content(film)
        getMovieBanner(for: film)
    }
    
    func updateUI() {
        switch currentState {
        case .noFilmSelected:
            delegate?.didUpdateWithEmptyState()
        case .content(_,_):
            delegate?.didUpdateFilmDetails()
        }
    }
    
    func getMovieBanner(for film: Film) {
        let fallbackImage = SFSymbols.movieClapper
        guard let url = URL(string: film.movieBanner) else {
            currentState = .content(film, image: fallbackImage)
            return
        }
        
        imageLoadTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            let downloadedImage = await imageLoader.loadImage(from: url)
            if !Task.isCancelled {
                currentState = .content(film, image: downloadedImage ?? fallbackImage)
            } else {
                currentState = .content(film, image: fallbackImage)
            }
        }
    }
}
