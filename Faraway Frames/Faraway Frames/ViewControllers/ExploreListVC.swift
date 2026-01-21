//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreListVC: UIViewController {
    
    enum Section: Int { case main }
    
    private(set) var films: [Film] = []
    let viewModel: FilmsListViewModel
    weak var alertPresenter: AlertPresenter?
    lazy var collectionView = UICollectionView()
    var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!

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
        configureCollectionView()
        configureDataSource()
        getAllFilms()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let width = layoutEnvironment.container.effectiveContentSize.width
            let columnCount = self.columnCount(for: width)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(150))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columnCount)
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 10, bottom: 10, trailing: 10)
            
            return section
        }
    }
    
    func columnCount(for width: CGFloat) -> Int {
        width > 800 ? 3 : 1
    }
    
    private func configureDataSource() {
        let filmCellRegistration = UICollectionView.CellRegistration<ExploreListCell, Film> { (cell, indexPath, film) in
            var config = UIListContentConfiguration.cell()
            config.text = film.title
            config.image = UIImage(systemName: "photo")
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
            
            var background = UIBackgroundConfiguration.listCell()
            background.backgroundColor = .secondarySystemBackground
            background.cornerRadius = 8
            cell.backgroundConfiguration = background
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, film) -> ExploreListCell in
            let film = self.films.first(where: { $0.id == film })
            let cell = collectionView.dequeueConfiguredReusableCell(using: filmCellRegistration, for: indexPath, item: film)
            return cell
        })
    }
    
    private func getAllFilms() {
        Task {
            await viewModel.getAllFilms()
        }
    }
}

extension ExploreListVC: UICollectionViewDelegate {
}

extension ExploreListVC: FilmsListViewModelDelegate {
    func didUpdateFilms(_ films: [Film]) {
        self.films = films
        let filmIds = films.map({ $0.id })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filmIds, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func didFailToLoadFilms(withError error: APIError) {
        let alertVC = UIAlertController(title: "Error: \(error)", message: "Failed to load films", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        alertVC.modalPresentationStyle = .automatic
        alertVC.modalTransitionStyle = .crossDissolve
        alertPresenter?.present(alertVC, animated: true, completion: nil)
    }
}
