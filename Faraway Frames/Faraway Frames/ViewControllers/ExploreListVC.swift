//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreListVC: UIViewController {
    private(set) var films: [Film] = []
    let viewModel: FilmsListViewModel
    weak var alertPresenter: AlertPresenter?
    
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
        if alertPresenter == nil { alertPresenter = self }
        viewModel.delegate = self
        getAllFilms()
    }
    
    private func getAllFilms() {
        Task {
           await viewModel.getAllFilms()
        }
    }
}

extension ExploreListVC: FilmsListViewModelDelegate {
    func didUpdateFilms(_ films: [Film]) {
        self.films = films
    }
    
    func didFailToLoadFilms(withError error: APIError) {
        let alertVC = UIAlertController(title: "Error: \(error)", message: "Failed to load films", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        alertVC.modalPresentationStyle = .automatic
        alertVC.modalTransitionStyle = .crossDissolve
        alertPresenter?.present(alertVC, animated: true, completion: nil)
    }
}
