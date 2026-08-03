//
//  HomeVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/03/2026.
//

import UIKit
import CoreData

final class HomeVC: UIViewController {
    // MARK: - Diffable DataSource Section Identifier Type
    enum Section: Int, Hashable, Sendable {
        case upNext
        case watched
    }
    
    // MARK: - Properties
    private(set) var films: [Film] = []
    private(set) var segmentedControlIndex = 0
    let homeViewModel: HomeViewModel
    lazy var collectionView = UICollectionView()
    private var filmCellRegistration: UICollectionView.CellRegistration<FilmGridCell, Film>!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!
    private(set) var emptyStateView = UIContentUnavailableView(configuration: .empty())
    private(set) var databaseErrorView = UIContentUnavailableView(configuration: .empty())
    
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
        navigationItem.largeTitleDisplayMode = CurrentDevice.isIPhone ? .inline : .automatic
        title = "Home"
        homeViewModel.delegate = self
        configureCollectionView()
        configureCellRegistration()
        configureDataSource()
        homeViewModel.performFetches()
        registerForTraitChanges([UITraitHorizontalSizeClass.self, UITraitVerticalSizeClass.self]) { [weak self] (vc: Self, previousTraitCollection: UITraitCollection) in
            guard let self = self else { return }
            transitionLayout(toWidth: self.view.bounds.width)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            transitionLayout(toWidth: size.width)
        })
    }
    
    func transitionLayout(toWidth width: CGFloat) {
        collectionView.collectionViewLayout.invalidateLayout()
        let freshLayout = createLayout(for: width)
        collectionView.setCollectionViewLayout(freshLayout, animated: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout(for: view.bounds.width)
        )
        collectionView.delegate = self
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
    
    private func configureCellRegistration() {
        filmCellRegistration =
        UICollectionView.CellRegistration<FilmGridCell, Film> { [weak self] cell, _, film in
            guard let self else { return }
            cell.configure(with: film)
            if let image = homeViewModel.checkCachesForFilmPoster(for: film) {
                cell.updateImage(image)
            }
        }
    }
    
    private func createLayout(for width: CGFloat) -> UICollectionViewLayout {
        let hSizeClass = traitCollection.horizontalSizeClass
        let vSizeClass = traitCollection.verticalSizeClass
        
        let numberOfColumns = LayoutMetrics.columnCount(horizontal: hSizeClass, vertical: vSizeClass)
        let itemFraction = 1.0 / CGFloat(numberOfColumns)
        
        // Lower the baseline estimate for compact vertical size classes
        let baselineEstimate: CGFloat = (vSizeClass == .compact) ? 140.0 : 180.0
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemFraction),
            heightDimension: .estimated(baselineEstimate)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: LayoutMetrics.uniformSpacing,
            bottom: 0,
            trailing: LayoutMetrics.uniformSpacing
        )
        
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: .fixed(LayoutMetrics.halfSpacing),
            trailing: nil,
            bottom: .fixed(LayoutMetrics.halfSpacing)
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(baselineEstimate)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: LayoutMetrics.halfSpacing,
            leading: LayoutMetrics.uniformSpacing,
            bottom: LayoutMetrics.uniformSpacing,
            trailing: LayoutMetrics.uniformSpacing
        )
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(52)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        sectionHeader.pinToVisibleBounds = false
        
        section.boundarySupplementaryItems = [sectionHeader]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Data Source Configuration
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Film.ID>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, filmID in
            guard let self = self else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: UICollectionView.CellRegistration<UICollectionViewCell, Film.ID> { cell, _, _ in },
                    for: indexPath,
                    item: filmID
                )
            }
            
            guard let section = Section(rawValue: segmentedControlIndex) else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: filmCellRegistration,
                    for: indexPath,
                    item: Film.placeholder
                )
            }
            
            let film: Film?
            switch section {
            case .upNext:
                film = homeViewModel.lookupUpNextFilm(for: filmID)
            case .watched:
                film = homeViewModel.lookupWatchedFilm(for: filmID)
            }
            
            guard let film else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: filmCellRegistration,
                    for: indexPath,
                    item: Film.placeholder
                )
            }
            requestImageIfNeeded(for: film)
            
            return collectionView.dequeueConfiguredReusableCell(
                using: filmCellRegistration,
                for: indexPath,
                item: film
            )
        }
    }
    
    /// Decides whether to start the work.
    private func requestImageIfNeeded(for film: Film) {
        guard homeViewModel.checkCachesForFilmPoster(for: film) == nil else { return }
        
        Task { [weak self] in
            await self?.loadImageAndRefreshItem(for: film)
        }
    }
    
    /// Performs the async work.
    private func loadImageAndRefreshItem(for film: Film) async {
        guard await homeViewModel.getImage(for: film) != nil else { return }
        reconfigureItem(film.id)
    }
    
    /// Updates the diffable data source.
    private func reconfigureItem(_ filmID: Film.ID) {
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(filmID) != nil else { return }
        snapshot.reconfigureItems([filmID])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        let activeSection: Section = (segmentedControlIndex == 0) ? .upNext : .watched
        snapshot.appendSections([activeSection])
        
        films = films(for: activeSection)
        snapshot.appendItems(films.map(\.id), toSection: activeSection)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        switch homeViewModel.currentState {
        case .failure(let error):
            showErrorView(for: activeSection, error: error)
            hideEmptyStateView()
        case .idle, .fetchedObjects:
            hideDatabaseErrorView()
            if films.isEmpty {
                showEmptyState(for: activeSection)
            } else {
                hideEmptyStateView()
            }
        }
    }
    
    private func films(for section: Section) -> [Film] {
        switch section {
        case .upNext:  return homeViewModel.upNextFilms
        case .watched: return homeViewModel.watchedFilms
        }
    }
    
    private func showErrorView(for section: Section, error: HomeError) {
        updateStateView(
            databaseErrorView,
            image: SFSymbols.exclamationMarkTriangle,
            text: error.localizedDescription,
            secondaryText: error.secondaryText,
            accessibilityIdentifier: "HomeVC_ErrorView"
        )
    }
    
    private func showEmptyState(for section: Section) {
        let secondaryText: String
        switch section {
        case .upNext:
            secondaryText = "Films added to Up Next appear here"
        case .watched:
            secondaryText = "Films added to Watched appear here"
        }
        updateStateView(emptyStateView,
                        image: SFSymbols.movieClapper,
                        text: "Empty Queue",
                        secondaryText: secondaryText,
                        accessibilityIdentifier: "HomeVC_EmptyStateView"
        )
    }
    
    private func updateStateView(
        _ stateView: UIContentUnavailableView,
        image: UIImage?,
        text: String?,
        secondaryText: String?,
        accessibilityIdentifier: String
    ) {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = image
        config.text = text
        config.secondaryText = secondaryText
        stateView.configuration = config
        stateView.isAccessibilityElement = true
        stateView.accessibilityTraits = [.staticText]
        stateView.accessibilityLabel = [text, secondaryText]
            .compactMap { $0 }
            .joined(separator: ". ")
        stateView.accessibilityIdentifier = accessibilityIdentifier
        view.addSubview(stateView)
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.isHidden = false
        
        NSLayoutConstraint.activate([
            stateView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            stateView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
    
    private func hideDatabaseErrorView() {
        databaseErrorView.isHidden = true
        databaseErrorView.isAccessibilityElement = false
    }
    
    private func hideEmptyStateView() {
        emptyStateView.isHidden = true
        emptyStateView.isAccessibilityElement = false
    }
    
    // MARK: - Segmented Control Action
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        segmentedControlIndex = sender.selectedSegmentIndex
        updateSnapshot()
    }
}

// MARK: - Home View Model Delegate
extension HomeVC: HomeViewModelDelegate {
    func homeViewModelDidUpdate() {
        updateSnapshot()
    }
}

// MARK: - Collection View Delegate
extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeSection: Section = (segmentedControlIndex == 0) ? .upNext : .watched
        let filmQueue: FilmQueue
        if activeSection == .upNext {
            filmQueue = .upNext
        } else {
            filmQueue = .watched
        }
        guard let filmID = dataSource.itemIdentifier(for: indexPath) else { return }
        homeViewModel.selectFilm(at: filmID, in: filmQueue)
    }
}

// MARK: - Layout Metrics Extension
/// Provides spacing and poster aspect ratio constants, and column count calculation based on size classes for collection view layout.
extension HomeVC {
    enum LayoutMetrics {
        static let uniformSpacing: CGFloat = 8.0
        static let halfSpacing: CGFloat = 4.0
        static let posterAspectRatio: CGFloat = 1.3
        // Calculate columns by inspecting both width and height environments
        static func columnCount(horizontal: UIUserInterfaceSizeClass, vertical: UIUserInterfaceSizeClass) -> Int {
            // If the height is compact (iPhone Landscape), increase columns to shrink the posters.
            if vertical == .compact {
                return 4
            }
            
            // Otherwise fall back to standard width-based layout constraints.
            switch horizontal {
            case .compact:  return 2
            case .regular:  return 4
            case .unspecified: return 2
            @unknown default: return 2
            }
        }
    }
}

// MARK: - Preview
#Preview("Home VC") {
    let testPersistenceController = try! PersistenceController(inMemory: true)
    let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
    let mockUpNextFRC = NSFetchedResultsController(
        fetchRequest: FilmMO.upNextFetchRequest(),
        managedObjectContext: testPersistenceController.viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
    )
    let mockWatchedFRC = NSFetchedResultsController(
        fetchRequest: FilmMO.watchedFetchRequest(),
        managedObjectContext: testPersistenceController.viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
    )
    let imageLoader = APIClientImageLoader(cacheManager: CacheManager())
    let vm = HomeViewModel(upNextFRC: mockUpNextFRC, watchedFRC: mockWatchedFRC, imageLoader: imageLoader, filmQueueService: filmQueueService)
    let vc = HomeVC(homeViewModel: vm)
    vc
}
