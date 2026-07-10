//
//  HomeVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/03/2026.
//

import UIKit

final class HomeVC: UIViewController {
    // MARK: - Diffable DataSource Section Identifier Type
    enum Section: Int, Hashable, Sendable {
        case upNext
    }
    
    // MARK: - Properties
    let homeViewModel: HomeViewModel
    lazy var collectionView = UICollectionView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!
    
    // MARK: - Initialisation
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
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
        homeViewModel.delegate = self
        configureCollectionView()
        configureDataSource()
        homeViewModel.performFetches()
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
    
    // MARK: - Data Source Configuration
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(collectionView: collectionView) { [weak self] collectionView, indexPath, filmID in
            guard let self = self,
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmGridCell.reuseID, for: indexPath) as? FilmGridCell else {
                fatalError("Unable to dequeue FilmGridCell")
            }
            let film = homeViewModel.lookupUpNextFilm(for: filmID)
            if let film = film {
                cell.configure(with: film)
            }
            return cell
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        snapshot.appendSections([.upNext])
        let upNextFilmsIds = homeViewModel.upNextFilms.map({ $0.id })
        snapshot.appendItems(upNextFilmsIds, toSection: .upNext)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        if homeViewModel.upNextFilms.isEmpty {
            showEmptyState(forUpNext: true)
        }
    }
    
    private func showEmptyState(forUpNext: Bool) {
        let config = UIContentUnavailableConfiguration.empty()
        contentUnavailableConfiguration = config
    }
}

// MARK: - Home View Model Delegate
extension HomeVC: HomeViewModelDelegate {
    func filmsDidChange(_ upNextFilms: [Film], _ watchedFilms: [Film]) {
        updateSnapshot()
    }
    
    func didReceiveError(_ error: HomeError) {
    }
}
