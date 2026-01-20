//
//  ExploreListViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreListVC: UIViewController {
    
    nonisolated enum Section { case main }
    
    private(set) var films: [Film] = []
    let viewModel: FilmsListViewModel
    weak var alertPresenter: AlertPresenter?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    var dataSource: UICollectionViewDiffableDataSource<Section, Film>!

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
        configureDataSource()
        configureCollectionView()
        getAllFilms()
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Film>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, film) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            return cell
        })
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
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
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film>()
        snapshot.appendSections([.main])
        snapshot.appendItems(films)
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
