//
//  HomeVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/03/2026.
//

import UIKit

final class HomeVC: UIViewController {
    
    // MARK: - Properties
    let upNextViewModel: HomeUpNextViewModel
    let watchedViewModel: HomeWatchedViewModel
    lazy var collectionView = UICollectionView()
    
    // MARK: - Initialisation
    init(upNextViewModel: HomeUpNextViewModel, watchedViewModel: HomeWatchedViewModel) {
        self.upNextViewModel = upNextViewModel
        self.watchedViewModel = watchedViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Home"
        upNextViewModel.delegate = self
        watchedViewModel.delegate = self
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return nil
        }
        return layout
    }
}

// MARK: - Up Next View Model Delegate
extension HomeVC: HomeUpNextViewModelDelegate {
    func upNextFilmsDidChange(_ films: [FilmWithStatus]) {
    }
}

// MARK: - Watched View Model Delegate
extension HomeVC: HomeWatchedViewModelDelegate {
}

// MARK: - Preview
//#Preview("HomeVC") {
//    let upNextViewModel = HomeUpNextViewModel()
//    let watchedViewModel = HomeWatchedViewModel()
//    let vc = HomeVC(upNextViewModel: upNextViewModel, watchedViewModel: watchedViewModel)
//    vc
//}
