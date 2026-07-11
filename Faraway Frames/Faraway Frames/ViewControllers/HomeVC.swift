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
    let homeViewModel: HomeViewModel
    lazy var collectionView = UICollectionView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Film.ID>!
    private(set) var films: [Film] = []
    
    // MARK: - UI Components
    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Up Next", "Watched"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
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
        setupSegmentedControl()
        configureCollectionView()
        configureDataSource()
        homeViewModel.performFetches()
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func segmentChanged() {
        updateSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
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
        let activeSection: Section = (segmentedControl.selectedSegmentIndex == 0) ? .upNext : .watched
        snapshot.appendSections([activeSection])
        
        films = films(for: activeSection)
        snapshot.appendItems(films.map(\.id), toSection: activeSection)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        if films.isEmpty {
            showEmptyState(for: activeSection)
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    
    private func films(for section: Section) -> [Film] {
        switch section {
        case .upNext:  return homeViewModel.upNextFilms
        case .watched: return homeViewModel.watchedFilms
        }
    }
    
    private func showEmptyState(for section: Section) {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = SFSymbols.movieClapper
        config.text = "No Films Added Yet"
        switch section {
        case .upNext:
            config.secondaryText = "Films added to Up Next appear here"
        case .watched:
            config.secondaryText = "Films added to Watched appear here"
        }
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
    let vm = HomeViewModel(upNextFRC: mockUpNextFRC, watchedFRC: mockWatchedFRC, filmQueueService: filmQueueService)
    let vc = HomeVC(homeViewModel: vm)
    vc
}
