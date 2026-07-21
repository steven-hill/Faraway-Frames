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
    
    typealias Dependencies = FilmsListServicing & AccessibilityServicing
    private let dependencies: Dependencies
    private let imageLoader: ImageLoader
    private let filmQueueService: FilmQueueServiceProtocol
    private let filmSyncService: FilmSyncService
    let exploreSplitVC: UISplitViewController
    var exploreListVC: ExploreListVC?
    private(set) var filmDetailViewModel: FilmDetailViewModel
    
    init(dependencies: Dependencies,
         imageLoader: ImageLoader,
         filmQueueService: FilmQueueServiceProtocol,
         filmSyncService: FilmSyncService,
         exploreSplitVC: UISplitViewController = ExploreSplitVC(style: .doubleColumn)) {
        self.dependencies = dependencies
        self.imageLoader = imageLoader
        self.filmQueueService = filmQueueService
        self.filmSyncService = filmSyncService
        self.exploreSplitVC = exploreSplitVC
        filmDetailViewModel = FilmDetailViewModel(film: nil, imageLoader: imageLoader, filmQueueService: filmQueueService)
    }
    
    func start() {
        createExploreSplitVC()
    }
    
    private func createExploreSplitVC() {
        exploreSplitVC.preferredDisplayMode = .oneBesideSecondary
        exploreSplitVC.delegate = self
        let filmsListViewModel = FilmsListViewModel(filmsListService: dependencies.makeFilmsListService(), imageLoader: imageLoader, filmSyncService: filmSyncService)
        let exploreListVC = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: dependencies.makeAccessibilityService())
        exploreListVC.navigationDelegate = self
        self.exploreListVC = exploreListVC
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
        exploreSplitVC.view.layoutIfNeeded()
        filmDetailViewModel.setFilm(film)
        let detailVC = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        if let primaryNav = exploreSplitVC.viewController(for: .primary) as? UINavigationController {
            if let exploreListVC = self.exploreListVC {
                detailVC.delegate = exploreListVC
            }
            if exploreSplitVC.isCollapsed {
                primaryNav.pushViewController(detailVC, animated: true)
                return
            }
        }
        
        exploreSplitVC.showDetailViewController(detailVC, sender: nil)
        
        if exploreSplitVC.isCollapsed == false {
            exploreSplitVC.hide(.primary)
        }
    }
}
