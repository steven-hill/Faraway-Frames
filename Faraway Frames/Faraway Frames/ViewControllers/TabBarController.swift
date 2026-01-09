//
//  TabBarController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/01/2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [createExploreTab()]
    }
    
    private func createExploreTab() -> UISplitViewController {
        let exploreSplitVC = ExploreSplitVC(style: .doubleColumn)
        exploreSplitVC.preferredDisplayMode = .oneBesideSecondary
        exploreSplitVC.delegate = self
        
        let exploreListVC = ExploreListVC()
        let exploreListNav = UINavigationController(rootViewController: exploreListVC)
        exploreSplitVC.setViewController(exploreListNav, for: .primary)
        
        let exploreDetailVC = ExploreDetailVC()
        let exploreDetailNav = UINavigationController(rootViewController: exploreDetailVC)
        exploreSplitVC.setViewController(exploreDetailNav, for: .secondary)
        
        exploreSplitVC.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "film"),
            tag: 0
        )
        
        return exploreSplitVC
    }
}

extension TabBarController: UISplitViewControllerDelegate {
    func splitViewController(
        _ splitViewController: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        
        guard
            let secondaryNavController = splitViewController.viewController(for: .secondary) as? UINavigationController,
            let secondaryRootVC = secondaryNavController.viewControllers.first
        else {
            return .primary
        }
        
        return topColumnForCollapsing(secondaryRootVC: secondaryRootVC)
    }
    
    // MARK: - Helper method
    func topColumnForCollapsing(
        secondaryRootVC: UIViewController?
    ) -> UISplitViewController.Column {
        
        if secondaryRootVC is ExploreDetailVC {
            return .primary
        } else {
            return .secondary
        }
    }
}
