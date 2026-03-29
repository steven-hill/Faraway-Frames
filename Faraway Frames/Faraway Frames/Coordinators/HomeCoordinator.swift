//
//  HomeCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/03/2026.
//

import UIKit

final class HomeCoordinator: Coordinator {
    let homeVC: UIViewController
    var navigationController = UINavigationController()
    
    init(homeVC: UIViewController = HomeVC(upNextViewModel: HomeUpNextViewModel(), watchedViewModel:    HomeWatchedViewModel())) {
        self.homeVC = homeVC
    }
    
    func start() {
        navigationController = UINavigationController(rootViewController: homeVC)
    }
}
