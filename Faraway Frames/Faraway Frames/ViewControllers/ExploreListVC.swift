//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreListVC: UIViewController {
    
    enum Section: Int { case main }
    
    // MARK: - Properties
    private(set) var films: [Film] = []
    var filmImage: UIImage?
    private(set) var filmLookup: [String: Film] = [:]
    let viewModel: FilmsListViewModel
    lazy var collectionView = UICollectionView()
    var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!
    let searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: FilmsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Explore"
        viewModel.delegate = self
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        getAllFilms()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
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
    
    func updateCellImage(_ cell: UICollectionViewCell, film: Film, indexPath: IndexPath) async {
        filmImage = await viewModel.getImage(for: film)
        
        guard let currentIndexPath = collectionView.indexPath(for: cell),
                currentIndexPath == indexPath else { return }
        
        var updatedConfig = cell.contentConfiguration as? UIListContentConfiguration
        updatedConfig?.image = filmImage ?? UIImage(systemName: "photo")
        cell.contentConfiguration = updatedConfig
    }
    
    private func configureDataSource() {
        let filmCellRegistration = UICollectionView.CellRegistration<ExploreListCell, Film> { [weak self] (cell, indexPath, film) in
            guard let self else { return }
            var config = UIListContentConfiguration.cell()
            config.text = film.title
            config.image = UIImage(systemName: "photo")
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
            
            var background = UIBackgroundConfiguration.listCell()
            background.backgroundColor = .tertiarySystemBackground
            background.cornerRadius = 8
            cell.backgroundConfiguration = background
            
            Task {
                await updateCellImage(cell, film: film, indexPath: indexPath)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, filmID) -> ExploreListCell in
            guard let film = self.filmLookup[filmID] else {
                return collectionView.dequeueConfiguredReusableCell(using: filmCellRegistration, for: indexPath, item: Film.sample)
            }
            return collectionView.dequeueConfiguredReusableCell(using: filmCellRegistration, for: indexPath, item: film)
        })
    }
    
    private func getAllFilms() {
        Task {
            await viewModel.getAllFilms()
        }
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        var config: UIContentUnavailableConfiguration? = nil
        var collectionViewIsHidden = true
        var searchBarIsEnabled = false
        switch viewModel.currentState {
        case .loadingAllFilms:
            config = createLoadingConfig()
        case .content:
            config = nil
            collectionViewIsHidden = false
            searchBarIsEnabled = true
        case .emptySearchResults:
            config = createEmptySearchResultsConfig()
            searchBarIsEnabled = true
        case .error(let error):
            config = createErrorConfig(error: error)
        }
        self.contentUnavailableConfiguration = config
        self.collectionView.isHidden = collectionViewIsHidden
        self.searchController.searchBar.isEnabled = searchBarIsEnabled
    }
    
    private func createLoadingConfig() -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.loading()
        config.text = "Fetching films..."
        config.textProperties.color = .systemGray
        return config
    }
    
    private func createEmptySearchResultsConfig() -> UIContentUnavailableConfiguration {
        var searchConfig = UIContentUnavailableConfiguration.search()
        searchConfig.text = "No Results"
        searchConfig.secondaryText = "Try a different search term."
        return searchConfig
    }
    
    private func createErrorConfig(error: APIError) -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = "Error loading films: \(error.description)"
        config.image = UIImage(systemName: "exclamationmark.triangle")
        config.imageProperties.tintColor = .systemRed
        config.button = .prominentGlass()
        config.button.title = "Retry"
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            Task { await self?.viewModel.retryLoadingAllFilms() }
        }
        return config
    }
    
    //MARK: - Search Controller
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search films"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func resetFilmsToAllFilms() {
        viewModel.resetAllFilms()
    }
}

// MARK: - Collection View Delegate
extension ExploreListVC: UICollectionViewDelegate {
}

// MARK: - Films List View Model Delegate
extension ExploreListVC: FilmsListViewModelDelegate {
    func didUpdateFilms(_ films: [Film]) {
        self.films = films
        let filmIds = films.map({ $0.id })
        filmLookup = Dictionary(uniqueKeysWithValues: films.map { ($0.id, $0) })

        setNeedsUpdateContentUnavailableConfiguration()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filmIds, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func didFailToLoadFilms(withError error: APIError) {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    func didFailToMatchResults() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

// MARK: - Search Bar Delegate
extension ExploreListVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        resetFilmsToAllFilms()
    }
}

// MARK: - Search Results Updating
extension ExploreListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        guard !films.isEmpty else { return }
        viewModel.filterFilms(by: searchText)
    }
}

