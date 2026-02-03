//
//  MainCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 03/02/2026.
//

import Foundation
import UIKit

final class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var window: WindowProtocol
    typealias Dependencies = FilmsListServicing & ImageLoading
    let dependencies: Dependencies
    let tabBarController = TabBarController()
    
    init(window: WindowProtocol, dependencies: Dependencies) {
        self.window = window
        self.dependencies = dependencies
    }
    
    func start() {
        let exploreSplitViewCoordinator = ExploreSplitViewCoordinator(dependencies: dependencies)
        exploreSplitViewCoordinator.start()
        childCoordinators.append(exploreSplitViewCoordinator)
        
        tabBarController.tabs = [
            UITab(title: "Explore", image: UIImage(systemName: "film"), identifier: "exploreTab") { _ in
                return exploreSplitViewCoordinator.exploreSplitVC
            }
        ]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
