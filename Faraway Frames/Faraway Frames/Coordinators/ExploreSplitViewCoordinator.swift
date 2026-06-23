//
//  ExploreSplitViewCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 03/02/2026.
//

import Foundation
import UIKit
import CoreData

final class ExploreSplitViewCoordinator: Coordinator {
    
    typealias Dependencies = FilmsListServicing & ImageLoading
    private let dependencies: Dependencies
    private let filmQueueService: FilmQueueService
    private let filmSyncService: FilmSyncService
    let exploreSplitVC: UISplitViewController
    private(set) var filmDetailViewModel: FilmDetailViewModel
    
    init(dependencies: Dependencies,
         filmQueueService: FilmQueueService,
         filmSyncService: FilmSyncService,
         exploreSplitVC: UISplitViewController = ExploreSplitVC(style: .doubleColumn)) {
        self.dependencies = dependencies
        self.filmQueueService = filmQueueService
        self.filmSyncService = filmSyncService
        self.exploreSplitVC = exploreSplitVC
        filmDetailViewModel = FilmDetailViewModel(film: nil, imageLoader: dependencies.makeImageLoader(), filmQueueService: filmQueueService)
    }
    
    func start() {
        createExploreSplitVC()
    }
    
    private func createExploreSplitVC() {
        exploreSplitVC.preferredDisplayMode = .oneBesideSecondary
        exploreSplitVC.delegate = self
        let filmsListViewModel = FilmsListViewModel(filmsListService: dependencies.makeFilmsListService(), imageLoader: dependencies.makeImageLoader(), filmSyncService: filmSyncService)
        let exploreListVC = ExploreListVC(viewModel: filmsListViewModel)
        exploreListVC.navigationDelegate = self 
        let exploreListNav = UINavigationController(rootViewController: exploreListVC)
        exploreSplitVC.setViewController(exploreListNav, for: .primary)
        
        let exploreDetailVC = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        let exploreDetailNav = UINavigationController(rootViewController: exploreDetailVC)
        exploreSplitVC.setViewController(exploreDetailNav, for: .secondary)
    }
}

extension ExploreSplitViewCoordinator: UISplitViewControllerDelegate {
    func splitViewController(
        _ splitViewController: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        return .primary
    }
}

extension ExploreSplitViewCoordinator: ExploreNavigationDelegate {
    var shouldDeselectAfterSelection: Bool {
        return exploreSplitVC.isCollapsed
    }
    
    func didSelectFilm(_ film: Film) {
        filmDetailViewModel.setFilm(film)
        exploreSplitVC.showDetailViewController(ExploreDetailVC(filmDetailViewModel: filmDetailViewModel), sender: nil)
        if exploreSplitVC.isCollapsed == false {
            exploreSplitVC.hide(.primary)
        }
    }
}
