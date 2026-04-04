//
//  HomeWatchedViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 26/03/2026.
//

import Foundation

final class HomeWatchedViewModel {
    
    // MARK: - State Definition
    enum HomeWatchedState {
        case noFilms
    }

    // MARK: - Properties
    private(set) var currentState: HomeWatchedState = .noFilms
    private(set) var watchedFilms: [Film] = []
    weak var delegate: HomeWatchedViewModelDelegate?
}
