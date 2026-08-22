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
    private let context: NSManagedObjectContext
    private let filmQueueService: FilmQueueServiceProtocol
    private let filmSyncService: FilmSyncService
    let exploreSplitVC: UISplitViewController
    private(set) var filmDetailViewModel: FilmDetailViewModel
    private let frcFactory: FilmDetailFRCFactory
    private let foundationModelsClient: FoundationModelsService
    
    init(dependencies: Dependencies,
         imageLoader: ImageLoader,
         context: NSManagedObjectContext,
         filmQueueService: FilmQueueServiceProtocol,
         filmSyncService: FilmSyncService,
         exploreSplitVC: UISplitViewController = ExploreSplitVC(style: .doubleColumn),
         frcFactory: FilmDetailFRCFactory,
         foundationModelsClient: FoundationModelsService) {
        self.dependencies = dependencies
        self.imageLoader = imageLoader
        self.context = context
        self.filmQueueService = filmQueueService
        self.filmSyncService = filmSyncService
        self.exploreSplitVC = exploreSplitVC
        self.frcFactory = frcFactory
        self.foundationModelsClient = foundationModelsClient
        filmDetailViewModel = FilmDetailViewModel(imageLoader: imageLoader,
                                                  managedObjectContext: context,
                                                  frcFactory: frcFactory,
                                                  filmQueueService: filmQueueService
        )
    }
    
    func start() {
        createExploreSplitVC()
    }
    
    private func createExploreSplitVC() {
        exploreSplitVC.preferredDisplayMode = .oneBesideSecondary
        exploreSplitVC.delegate = self
        let filmsListViewModel = FilmsListViewModel(filmsListService: dependencies.makeFilmsListService(), imageLoader: imageLoader, filmSyncService: filmSyncService)
        let cellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let exploreListVC = ExploreListVC(viewModel: filmsListViewModel,
                                          cellConfigurator: cellConfigurator,
                                          accessibilityService: dependencies.makeAccessibilityService())
        exploreListVC.navigationDelegate = self
        let exploreListNav = UINavigationController(rootViewController: exploreListVC)
        exploreSplitVC.setViewController(exploreListNav, for: .primary)
        
        let exploreDetailVC = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        exploreDetailVC.navigationDelegate = self
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
        filmDetailViewModel.setFilm()
        let detailVC = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        detailVC.navigationDelegate = self
        if let primaryNav = exploreSplitVC.viewController(for: .primary) as? UINavigationController,
           let exploreListVC = primaryNav.viewControllers.first as? ExploreListVC {
            detailVC.delegate = exploreListVC
        }
        exploreSplitVC.showDetailViewController(detailVC, sender: nil)
        if exploreSplitVC.isCollapsed == false {
            exploreSplitVC.hide(.primary)
        }
    }
}

extension ExploreSplitViewCoordinator: ExploreDetailNavigationDelegate {
    func exploreDetailDidTapMoreLikeThisButton() {
        let assistantViewModel = AssistantViewModel(foundationModelsClient: foundationModelsClient)
        let assistantVC = AssistantVC(assistantViewModel: assistantViewModel)
        let navigationController = UINavigationController(rootViewController: assistantVC)
        exploreSplitVC.present(navigationController, animated: true)
    }
}
