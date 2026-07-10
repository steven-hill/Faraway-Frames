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
    
    private func updateSnapshot(upNextFilms: [Film], watchedFilms: [Film]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>()
        snapshot.appendSections([.upNext])
        let upNextFilmsIds = upNextFilms.map({ $0.id })
        snapshot.appendItems(upNextFilmsIds, toSection: .upNext)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        if upNextFilms.isEmpty {
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
        updateSnapshot(upNextFilms: upNextFilms, watchedFilms: watchedFilms)
    }
    
    func didReceiveError(_ error: HomeError) {
    }
}

// MARK: - Custom Grid Collection View Cell
final class FilmGridCell: UICollectionViewCell {
    static let reuseID = "FilmGridCell"
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.4), // 2:3 Poster Ratio
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with film: Film) {
        titleLabel.text = film.title
        posterImageView.image = SFSymbols.photo
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
    }
}
