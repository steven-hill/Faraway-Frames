//
//  FilmDetailViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation

protocol FilmDetailViewModelDelegate: AnyObject {
    func didUpdateFilmDetails()
    func didUpdateWithEmptyState()
    func didUpdateUpNextStatus(isUpNext: Bool)
}
