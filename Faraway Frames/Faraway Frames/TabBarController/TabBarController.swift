//
//  TabBarController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/01/2026.
//

import UIKit

final class TabBarController: UITabBarController {
    typealias Dependencies = FilmsListServicing & ImageLoading
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabs = [createExploreTab()]
        mode = .tabSidebar
    }
    
    private func createExploreTab() -> UITab {
        return UITab(title: "Explore", image: UIImage(systemName: "film"), identifier: "exploreTab") { _ in
            return self.createExploreSplitVC()
        }
    }
    
    private func createExploreSplitVC() -> UISplitViewController {
        let exploreSplitVC = ExploreSplitVC(style: .doubleColumn)
        exploreSplitVC.preferredDisplayMode = .oneBesideSecondary
        exploreSplitVC.delegate = self
        
        let filmsListViewModel = FilmsListViewModel(filmsListService: dependencies.makeFilmsListService(), imageLoader: dependencies.makeImageLoader())
        let exploreListVC = ExploreListVC(viewModel: filmsListViewModel)
        let exploreListNav = UINavigationController(rootViewController: exploreListVC)
        exploreSplitVC.setViewController(exploreListNav, for: .primary)
        
        let exploreDetailVC = ExploreDetailVC()
        let exploreDetailNav = UINavigationController(rootViewController: exploreDetailVC)
        exploreSplitVC.setViewController(exploreDetailNav, for: .secondary)
        return exploreSplitVC
    }
}

extension TabBarController: UISplitViewControllerDelegate {
    func splitViewController(
        _ splitViewController: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        return .primary
    }
}
