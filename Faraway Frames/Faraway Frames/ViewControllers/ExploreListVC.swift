//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreListVC: UIViewController {
    
    // MARK: - Diffable DataSource Section Identifier Type
    enum Section: Int { case main }
    
    // MARK: - Properties
    weak var navigationDelegate: ExploreNavigationDelegate?
    private(set) var films: [Film] = []
    private(set) var filmLookup: [String: Film] = [:]
    let viewModel: FilmsListViewModel
    lazy var collectionView = UICollectionView()
    var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!
    let searchController = UISearchController(searchResultsController: nil)
    private var isRetrying = false
    private(set) var loadTask: Task<Void, Never>?
    
    // MARK: - Initialisation
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
        loadTask = getAllFilms()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = .systemBackground
        config.showsSeparators = true
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func updateCellImage(_ cell: UICollectionViewCell, film: Film, indexPath: IndexPath) async {
        let filmImage = await viewModel.getImage(for: film)
        
        guard let currentIndexPath = collectionView.indexPath(for: cell),
                currentIndexPath == indexPath else { return }
        
        var updatedConfig = cell.contentConfiguration as? UIListContentConfiguration
        updatedConfig?.image = filmImage ?? UIImage(systemName: "photo")
        cell.contentConfiguration = updatedConfig
    }
    
    private func configureDataSource() {
        let filmCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Film> { [weak self] (cell, indexPath, film) in
            guard let self else { return }
            var config = UIListContentConfiguration.cell()
            config.text = film.title
            config.image = UIImage(systemName: "photo")
            let filmImageSize = CGSize(width: 100, height: 150)
            config.imageProperties.reservedLayoutSize = filmImageSize
            config.imageProperties.maximumSize = filmImageSize
            config.imageProperties.cornerRadius = 10
            config.imageToTextPadding = 12
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
            cell.backgroundConfiguration = UIBackgroundConfiguration.listCell()
            
            Task {
                await updateCellImage(cell, film: film, indexPath: indexPath)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, filmID) -> UICollectionViewListCell in
            guard let self = self, let film = self.filmLookup[filmID] else {
                return collectionView.dequeueConfiguredReusableCell(using: filmCellRegistration, for: indexPath, item: Film.sample)
            }
            return collectionView.dequeueConfiguredReusableCell(using: filmCellRegistration, for: indexPath, item: film)
        }
    }
    
    private func getAllFilms() -> Task<Void, Never> {
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
        config.text = "Error loading films"
        config.secondaryText = "\(error.description)"
        config.image = UIImage(systemName: "exclamationmark.triangle")
        config.imageProperties.tintColor = .systemRed
        config.button = .prominentGlass()
        config.button.title = isRetrying ? "Retrying..." : "Retry"
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            guard let self, self.isRetrying == false else { return }
            self.isRetrying = true
            self.setNeedsUpdateContentUnavailableConfiguration()
            
            Task { await self.viewModel.retryLoadingAllFilms()
                self.isRetrying = false
                self.setNeedsUpdateContentUnavailableConfiguration()
            }
        }
        return config
    }
    
    //MARK: - Search Controller
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search films"
        searchController.searchBar.searchTextField.font = .preferredFont(forTextStyle: .title3)
        searchController.searchBar.searchTextField.accessibilityIdentifier = "ExploreListVC_SearchBar_SearchField"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func resetFilmsToAllFilms() {
        viewModel.resetAllFilms()
    }
}

// MARK: - Collection View Delegate
extension ExploreListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let filmId = dataSource.itemIdentifier(for: indexPath),
              let selectedFilm = filmLookup[filmId] else { return }
        navigationDelegate?.didSelectFilm(selectedFilm)
        if navigationDelegate?.shouldDeselectAfterSelection == true {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
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
    
    func didFailToLoadFilms() {
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

