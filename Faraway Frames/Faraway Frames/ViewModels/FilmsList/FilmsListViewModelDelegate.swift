//
//  FilmsListViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/01/2026.
//

import Foundation

protocol FilmsListViewModelDelegate: AnyObject {
    func didStartLoadingFilms()
    func didUpdateFilms()
    func didFailToLoadFilms()
    func didRetry()
    func didFailToMatchResults()
    func viewModel(
        _ viewModel: FilmsListViewModel,
        didEmit event: FilmsListViewModel.FilmsListEvent
    )
}
