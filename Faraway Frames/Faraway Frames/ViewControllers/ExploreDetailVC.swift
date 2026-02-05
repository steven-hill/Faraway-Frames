//
//  ExploreDetailViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

class ExploreDetailVC: UIViewController {
    let filmDetailViewModel: FilmDetailViewModel
    
    init(filmDetailViewModel: FilmDetailViewModel) {
        self.filmDetailViewModel = filmDetailViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filmDetailViewModel.delegate = self
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        var config: UIContentUnavailableConfiguration? = nil
        switch filmDetailViewModel.currentState {
        case .noFilmSelected:
            config = createEmptyState()
        case .content(let film):
            config = nil
            title = film.title
        }
        self.contentUnavailableConfiguration = config
    }
    
    private func createEmptyState() -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = UIImage(systemName: "movieclapper")
        config.text = "No Film Selected"
        config.secondaryText = "Pick a film from the list to see the details."
        return config
    }
}

// MARK: - Film Detail View Model Delegate
extension ExploreDetailVC: FilmDetailViewModelDelegate {
    func didUpdateFilmDetails() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    func didUpdateWithEmptyState() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
}
