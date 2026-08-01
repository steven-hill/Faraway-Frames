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
    private(set) var currentStateView: UIView?
    private let cellConfigurator: FilmRowCellConfigurator
    private var headerRegistration: UICollectionView.SupplementaryRegistration<NetworkErrorHeaderView>!
    private var filmCellRegistration: UICollectionView.CellRegistration<FilmRowCell, Film>!
    var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!
    let searchController = UISearchController(searchResultsController: nil)
    private(set) var loadTask: Task<Void, Never>?
    private let accessibilityService: AccessibilityService
    private(set) var voiceOverAnnouncementTask: Task<Void, Never>?
    
    // MARK: - Initialisation
    init(viewModel: FilmsListViewModel,
         cellConfigurator: FilmRowCellConfigurator,
         accessibilityService: AccessibilityService) {
        self.viewModel = viewModel
        self.cellConfigurator = cellConfigurator
        self.accessibilityService = accessibilityService
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
        configureSupplementaryRegistration()
        configureCellRegistration()
        configureDataSource()
        configureSearchController()
        configureRefreshControl()
        loadTask = getAllFilms()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadTask?.cancel()
        voiceOverAnnouncementTask?.cancel()
        loadTask = nil
        voiceOverAnnouncementTask = nil
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
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            config.backgroundColor = .systemBackground
            config.headerMode = self.viewModel.currentState == .content(isUsingArchivedData: true) ? .supplementary : .none
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureSupplementaryRegistration() {
        headerRegistration = UICollectionView.SupplementaryRegistration<NetworkErrorHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { (_, _, _) in }
    }
    
    private func configureCellRegistration() {
        filmCellRegistration = UICollectionView.CellRegistration<FilmRowCell, Film> { [weak self] (cell, _, film) in
            guard let self else { return }
            cellConfigurator.configure(cell, with: film)
            setNeedsUpdateContentUnavailableConfiguration()
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, filmID) -> UICollectionViewListCell in
            guard let self = self else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: UICollectionView.CellRegistration<UICollectionViewListCell, Film.ID> { cell, _, _ in },
                    for: indexPath,
                    item: filmID
                )
            }
            
            guard let film = self.filmLookup[filmID] else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: filmCellRegistration,
                    for: indexPath,
                    item: Film.placeholder
                )
            }
            
            return collectionView.dequeueConfiguredReusableCell(
                using: filmCellRegistration,
                for: indexPath,
                item: film
            )
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, _, indexPath) in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }
    
    private func getAllFilms() -> Task<Void, Never> {
        Task {
            await viewModel.getAllFilms()
        }
    }
    
    private func updateViewHierarchyForCurrentState() {
        var collectionViewIsHidden = true
        var searchBarIsEnabled = false
        currentStateView?.removeFromSuperview()
        currentStateView = nil
        let newStateView: UIView?
        
        switch viewModel.currentState {
        case .idle, .loadingAllFilms:
            let loadingView = LoadingView(message: "Fetching films...")
        case .content(isUsingArchivedData: false), .content(isUsingArchivedData: true):
            config = nil
            collectionViewIsHidden = false
            searchBarIsEnabled = true
        case .emptySearchResults:
            config = createEmptySearchResultsConfig()
            searchBarIsEnabled = true
        case .error(let error):
            config = createErrorConfig(error: error)
        case .retrying:
            config = createLoadingConfig(with: "Retrying...")
        }
        
        self.contentUnavailableConfiguration = config
        self.collectionView.isHidden = collectionViewIsHidden
        self.searchController.searchBar.isEnabled = searchBarIsEnabled
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
        config.secondaryText = "\(error.localizedDescription)"
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
        self.films = films
        let filmIds = films.map({ $0.id })
        filmLookup = Dictionary(uniqueKeysWithValues: films.map { ($0.id, $0) })
        collectionView.refreshControl?.endRefreshing()
        
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
    
    func didRequestVoiceOverAnnouncement(with message: String) {
        guard accessibilityService.isVoiceOverRunning else { return }
        voiceOverAnnouncementTask?.cancel()
        voiceOverAnnouncementTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            accessibilityService.post(notification: .announcement, argument: message)
            voiceOverAnnouncementTask = nil
        }
    }
}

// MARK: - Search Bar Delegate
extension ExploreListVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        resetFilmsToAllFilms()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            resetFilmsToAllFilms()
        }
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

extension ExploreListVC: FilmDetailViewControllerDelegate {
    func filmDetailViewController(_ controller: ExploreDetailVC, didUpdateFilm updatedFilm: Film) {
        viewModel.updateFilmInArrays(updatedFilm)
    }
}
