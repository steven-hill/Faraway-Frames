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
        viewControllers = [createExploreVC()]
    }
    
    func createExploreVC() -> UINavigationController {
        let exploreVC = ExploreVC()
        exploreVC.title = "Explore"
        exploreVC.tabBarItem.image = UIImage(systemName: "film")
        exploreVC.tabBarItem.tag = 0
        return UINavigationController(rootViewController: exploreVC)
    }
}
