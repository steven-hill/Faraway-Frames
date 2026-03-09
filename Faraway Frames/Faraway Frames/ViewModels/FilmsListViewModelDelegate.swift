//
//  FilmsListViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/01/2026.
//

import Foundation

@MainActor
protocol FilmsListViewModelDelegate: AnyObject {
    func didUpdateFilms(_ films: [Film])
    func didFailToLoadFilms()
    func didRetry()
    func didFailToMatchResults()
}
