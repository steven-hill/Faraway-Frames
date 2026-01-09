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
