//
//  HomeUpNextViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 26/03/2026.
//

import Foundation

final class HomeUpNextViewModel {
    
    // MARK: - State Definition
    enum HomeUpNextState {
        case noFilms
    }
    
    // MARK: - Properties
    private(set) var currentState: HomeUpNextState = .noFilms
    private(set) var upNextFilms: [Film] = []
    weak var delegate: HomeUpNextViewModelDelegate?
}
