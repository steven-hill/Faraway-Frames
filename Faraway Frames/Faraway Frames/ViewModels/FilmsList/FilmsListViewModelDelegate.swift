//
//  FilmsListViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/01/2026.
//

import Foundation

protocol FilmsListViewModelDelegate: AnyObject {
    func viewModel(
        _ viewModel: FilmsListViewModel,
        didChange state: FilmsListViewModel.FilmsListState
    )
    func viewModel(
        _ viewModel: FilmsListViewModel,
        didEmit event: FilmsListViewModel.FilmsListEvent
    )
}
