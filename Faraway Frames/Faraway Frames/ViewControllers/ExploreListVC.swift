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
    var alertPresenter: AlertPresenting = AlertPresenter()
    
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
        view.accessibilityIdentifier = "ExploreListVC_View"
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        var config: UIContentUnavailableConfiguration? = nil
        switch viewModel.currentState {
        case .loadingAllFilms:
            config = createLoadingView()
        case .emptySearchResults:
            config = createEmptySearchResultsView()
            config = createLoadingView()
        default: break
        }
        self.contentUnavailableConfiguration = config
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
    
    // MARK: - UI Updates
    private func updateViewHierarchyForCurrentState() {
        var collectionViewIsHidden = true
        var searchBarIsEnabled = false
        currentStateView?.removeFromSuperview()
        currentStateView = nil
        let newStateView: UIView?
        
        switch viewModel.currentState {
        case .idle, .loadingAllFilms:
            setNeedsUpdateContentUnavailableConfiguration()
            let loadingView = LoadingView(message: "Fetching films...")
            loadingView.accessibilityIdentifier = "ExploreListVC_LoadingView"
            newStateView = loadingView
        case .content(isUsingArchivedData: false), .content(isUsingArchivedData: true):
            setNeedsUpdateContentUnavailableConfiguration()
            collectionViewIsHidden = false
            searchBarIsEnabled = true
            newStateView = nil
        case .emptySearchResults:
            newStateView = nil
            setNeedsUpdateContentUnavailableConfiguration()
            searchBarIsEnabled = true
        case .error(let error):
            setNeedsUpdateContentUnavailableConfiguration()
            let retryAction = AlertAction(title: "Retry", style: .default) { [weak self] _ in
                self?.retryButtonTapped()
            }
            alertPresenter.presentAlert(title: "Error loading films",
                                        message: error.localizedDescription,
                                        actions: [retryAction],
                                        from: self)
            newStateView = nil
        case .retrying:
            setNeedsUpdateContentUnavailableConfiguration()
            let loadingView = LoadingView(message: "Retrying...")
            loadingView.accessibilityIdentifier = "ExploreListVC_LoadingView"
            newStateView = loadingView
        }
        
        if let stateView = newStateView {
            view.addSubview(stateView)
            currentStateView = stateView
            let topAnchor = stateView is LoadingView ? view.topAnchor : view.safeAreaLayoutGuide.topAnchor
            NSLayoutConstraint.activate([
                stateView.topAnchor.constraint(equalTo: topAnchor),
                stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        self.collectionView.isHidden = collectionViewIsHidden
        self.searchController.searchBar.isEnabled = searchBarIsEnabled
    }
    
    private func createLoadingView(with text: String) -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.loading()
        config.text = text
        config.textProperties.font = .preferredFont(forTextStyle: .title1)
        config.textProperties.color = .systemGray
        return config
    }
    
    private func createEmptySearchResultsView() -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.search()
        config.text = "No Films Found"
        config.secondaryText = "Check spelling or try another search."
        return config
    }
    
    func retryButtonTapped() {
        viewModel.retryLoadingAllFilms()
        updateViewHierarchyForCurrentState()
    }
    
    //MARK: - Search Controller
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search films"
        searchController.searchBar.searchTextField.font = .preferredFont(forTextStyle: .title3)
        searchController.searchBar.searchTextField.accessibilityIdentifier = "ExploreListVC_SearchBar_SearchField"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
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
    func didStartLoadingFilms() {
        updateViewHierarchyForCurrentState()
    }
    
    func didUpdateFilms(_ films: [Film]) {
        self.films = films
        let filmIds = films.map({ $0.id })
        filmLookup = Dictionary(uniqueKeysWithValues: films.map { ($0.id, $0) })
        collectionView.refreshControl?.endRefreshing()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filmIds, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        updateViewHierarchyForCurrentState()
    }
    
    func didFailToLoadFilms() {
        collectionView.refreshControl?.endRefreshing()
        updateViewHierarchyForCurrentState()
    }
    
    func didRetry() {
        updateViewHierarchyForCurrentState()
    }
    
    func didFailToMatchResults() {
        updateViewHierarchyForCurrentState()
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
