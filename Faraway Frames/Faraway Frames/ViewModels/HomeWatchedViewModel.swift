//
//  HomeWatchedViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 26/03/2026.
//

import Foundation

final class HomeWatchedViewModel {
    // MARK: - Properties
    private(set) var watchedFilms: [Film] = []
    weak var delegate: HomeWatchedViewModelDelegate?
}
