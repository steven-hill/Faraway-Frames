//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreListVC: UIViewController {
    var films: [Film] = []
    let viewModel: FilmsListViewModel
    
    init(viewModel: FilmsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Explore"
        getAllFilms()
    }
    
    private func getAllFilms() {
        Task {
            do {
                try await viewModel.getAllFilms()
                films = viewModel.films
                print(films)
            } catch {
                // Present alert
            }
        }
    }
}
