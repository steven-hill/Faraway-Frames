//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit
import SwiftUI

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
        navigationItem.largeTitleDisplayMode = CurrentDevice.isIPhone ? .inline : .automatic
        title = "Explore"
        setUpBackButton()
        viewModel.delegate = self
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        configureRefreshControl()
        loadTask = getAllFilms()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadTask?.cancel()
        loadTask = nil
    }
    
    private func setUpBackButton() {
        let backButton = UIBarButtonItem()
        backButton.accessibilityLabel = "Back to films list"
        navigationItem.backBarButtonItem = backButton
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(NetworkErrorReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NetworkErrorReusableView.identifier)
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
        config.headerMode = viewModel.currentState == .content(isUsingArchivedData: true) ? .supplementary : .none
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    @MainActor
    func updateCellImage(_ cell: UICollectionViewCell, filmID: Film.ID, indexPath: IndexPath) async {
        guard let film = filmLookup[filmID] else { return }
        
        let filmImage = await viewModel.getImage(for: film)
        
        guard let currentIndexPath = collectionView.indexPath(for: cell),
              currentIndexPath == indexPath else { return }
        
        if let currentFilmID = dataSource.itemIdentifier(for: indexPath),
           currentFilmID != filmID {
            return
        }
        
        cell.contentConfiguration = UIHostingConfiguration {
            FilmRowView(film: film, image: filmImage)
        }
    }
    
    private func configureDataSource() {
        let filmCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Film> { [weak self] (cell, indexPath, film) in
            guard let self else { return }
            let placeholderImage = SFSymbols.photo
            
            cell.contentConfiguration = UIHostingConfiguration {
                FilmRowView(film: film, image: placeholderImage)
            }
            cell.accessories = [.disclosureIndicator()]
            
            Task { [weak self, weak cell] in
                guard let self, let cell else { return }
                await self.updateCellImage(cell, filmID: film.id, indexPath: indexPath)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, filmID) -> UICollectionViewListCell in
            guard let self = self, let film = self.filmLookup[filmID] else {
                return UICollectionViewListCell()
            }
            return collectionView.dequeueConfiguredReusableCell(using: filmCellRegistration, for: indexPath, item: film)
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NetworkErrorReusableView.identifier,
                for: indexPath
            ) as? NetworkErrorReusableView
            return header
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
        case .idle, .loadingAllFilms:
            config = createLoadingConfig(with: "Fetching films...")
        case .content(isUsingArchivedData: false), .content(isUsingArchivedData: true):
            config = nil
            collectionViewIsHidden = false
            searchBarIsEnabled = true
            viewModel.filteredFilms.count > 0 ? handleVoiceOverAnnouncement(for: viewModel.filteredFilms.count) : handleVoiceOverAnnouncement(with: "Showing all films")
        case .emptySearchResults:
            config = createEmptySearchResultsConfig()
            searchBarIsEnabled = true
            handleVoiceOverAnnouncement(with: "No results found")
        case .error(let error):
            config = createErrorConfig(error: error)
        case .retrying:
            config = createLoadingConfig(with: "Retrying...")
        }
        
        self.contentUnavailableConfiguration = config
        self.collectionView.isHidden = collectionViewIsHidden
        self.searchController.searchBar.isEnabled = searchBarIsEnabled
        UIAccessibility.post(notification: .layoutChanged, argument: config?.text)
    }
    
    private func createLoadingConfig(with text: String) -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.loading()
        config.text = text
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
        config.image = SFSymbols.exclamationMarkTriangle
        config.imageProperties.tintColor = .systemRed
        config.button = .prominentGlass()
        config.button.title = "Retry"
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.retryLoadingAllFilms()
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
        return config
    }
    
    //MARK: - Accessibility Helpers
    private func handleVoiceOverAnnouncement(for count: Int) {
        guard UIAccessibility.isVoiceOverRunning, count > 0 else { return }
        let message = String(format: NSLocalizedString("%d found", comment: "VoiceOver search results count"), count)
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    private func handleVoiceOverAnnouncement(with message: String) {
        guard UIAccessibility.isVoiceOverRunning, viewModel.filteredFilms.count == 0 else { return }
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            UIAccessibility.post(notification: .announcement, argument: message)
        }
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
    
    //MARK: - Refresh Control
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data...")
        refreshControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.retryLoadingAllFilms()
            setNeedsUpdateContentUnavailableConfiguration()
        }, for: .valueChanged)
        collectionView.refreshControl = refreshControl
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
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        self.films = films
        let filmIds = films.map({ $0.id })
        filmLookup = Dictionary(uniqueKeysWithValues: films.map { ($0.id, $0) })
        collectionView.refreshControl?.endRefreshing()
        setNeedsUpdateContentUnavailableConfiguration()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filmIds, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func didFailToLoadFilms() {
        collectionView.refreshControl?.endRefreshing()
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    func didRetry() {
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
