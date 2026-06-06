//
//  HomeCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/03/2026.
//

import UIKit
import CoreData

final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let persistentContainer: NSPersistentContainer
    
    init(navigationController: UINavigationController, persistentContainer: NSPersistentContainer) {
        self.navigationController = navigationController
        self.persistentContainer = persistentContainer
    }
    
    func start() {
        let homeViewModel = HomeViewModel(persistentContainer: persistentContainer)
        let homeVC = HomeVC(homeViewModel: homeViewModel)
        navigationController.setViewControllers([homeVC], animated: false)
    }
}
