//
//  ExploreSplitViewCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 03/02/2026.
//

import Foundation
import UIKit

final class ExploreSplitViewCoordinator: Coordinator {
    
    typealias Dependencies = FilmsListServicing & ImageLoading
    private let dependencies: Dependencies
    let exploreSplitVC: UISplitViewController
    
    init(dependencies: Dependencies, exploreSplitVC: UISplitViewController = ExploreSplitVC(style: .doubleColumn)) {
        self.dependencies = dependencies
        self.exploreSplitVC = exploreSplitVC
    }
    
    func start() {
        createExploreSplitVC()
    }
    
    private func createExploreSplitVC() {
        exploreSplitVC.preferredDisplayMode = .oneBesideSecondary
        exploreSplitVC.delegate = self
        
        let filmsListViewModel = FilmsListViewModel(filmsListService: dependencies.makeFilmsListService(), imageLoader: dependencies.makeImageLoader())
        let exploreListVC = ExploreListVC(viewModel: filmsListViewModel)
        exploreListVC.navigationDelegate = self 
        let exploreListNav = UINavigationController(rootViewController: exploreListVC)
        exploreSplitVC.setViewController(exploreListNav, for: .primary)
        
        let exploreDetailVC = ExploreDetailVC()
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
    }
}
