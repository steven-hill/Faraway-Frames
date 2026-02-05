//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation

final class FilmDetailViewModel {
    
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
    
    init(film: Film? = nil) {
        if let film {
            currentState = .content(film)
        }
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
}
