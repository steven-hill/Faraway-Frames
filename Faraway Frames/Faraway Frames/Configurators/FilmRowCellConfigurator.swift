//
//  FilmRowCellConfigurator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 24/07/2026.
//

import Foundation

final class FilmRowCellConfigurator {
    
    // MARK: - Dependency
    private let viewModel: FilmsListViewModel
    
    // MARK: - Initialisation
    init(viewModel: FilmsListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Method
    func configure(_ cell: FilmRowCellRepresentable, with film: Film) {
        cell.configureTitle(with: film.title)
        cell.imageTask?.cancel()
        cell.imageTask = Task { [weak cell] in
            let image = await viewModel.getImage(for: film)
            guard !Task.isCancelled, let cell = cell else { return }
            cell.configureImage(with: image)
        }
    }
}
