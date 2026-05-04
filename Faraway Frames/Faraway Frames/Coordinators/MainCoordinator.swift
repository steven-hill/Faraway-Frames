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
        let homeCoordinator = HomeCoordinator()
        homeCoordinator.start()
        childCoordinators.append(homeCoordinator)
        
        let exploreSplitViewCoordinator = ExploreSplitViewCoordinator(dependencies: dependencies)
        exploreSplitViewCoordinator.start()
        childCoordinators.append(exploreSplitViewCoordinator)
        
        let assistantCoordinator = AssistantCoordinator()
        assistantCoordinator.start()
        childCoordinators.append(assistantCoordinator)
        
        tabBarController.tabs = [
            UITab(title: "Home", image: SFSymbols.house, identifier: "homeTab") { _ in
                return homeCoordinator.navigationController
            },
            UITab(title: "Explore", image: SFSymbols.filmStack, identifier: "exploreTab") { _ in
                return exploreSplitViewCoordinator.exploreSplitVC
            },
            UITab(title: "Assistant", image: SFSymbols.sparkles, identifier: "assistantTab") { _ in
                return assistantCoordinator.navigationController
            }
        ]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
