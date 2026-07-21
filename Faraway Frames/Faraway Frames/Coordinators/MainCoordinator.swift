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
    typealias Dependencies = FilmsListServicing & ImageLoading & AccessibilityServicing
    let dependencies: Dependencies
    let persistenceController: PersistenceControlling
    let tabBarController = TabBarController()
    var homeCoordinator: HomeCoordinator?
    var exploreSplitViewCoordinator: ExploreNavigationDelegate?
    private(set) var homeTab: UITab?
    private(set) var exploreTab: UITab?
    
    init(window: WindowProtocol, dependencies: Dependencies, persistenceController: PersistenceControlling) {
        self.window = window
        self.dependencies = dependencies
        self.persistenceController = persistenceController
    }
    
    func start() {
        let managedObjectContext = persistenceController.viewContext
        let filmQueueService = FilmQueueService(context: managedObjectContext)
        let filmSyncService = FilmSyncService(context: managedObjectContext)
        let imageLoader = dependencies.makeImageLoader()
        
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController(),
                                              context: managedObjectContext,
                                              imageLoader: imageLoader,
                                              filmQueueService: filmQueueService)
        homeCoordinator.delegate = self
        homeCoordinator.start()
        self.homeCoordinator = homeCoordinator
        childCoordinators.append(homeCoordinator)
        
        let exploreSplitViewCoordinator = ExploreSplitViewCoordinator(dependencies: dependencies,
                                                                      imageLoader: imageLoader,
                                                                      filmQueueService: filmQueueService,
                                                                      filmSyncService: filmSyncService)
        exploreSplitViewCoordinator.start()
        self.exploreSplitViewCoordinator = exploreSplitViewCoordinator
        childCoordinators.append(exploreSplitViewCoordinator)
        
        let assistantCoordinator = AssistantCoordinator()
        assistantCoordinator.start()
        childCoordinators.append(assistantCoordinator)
        
        let homeTab = UITab(title: "Home", image: SFSymbols.house, identifier: "homeTab") { _ in
                return homeCoordinator.navigationController
            }
        self.homeTab = homeTab
        
        let exploreTab = UITab(title: "Explore", image: SFSymbols.filmStack, identifier: "exploreTab") { _ in
                return exploreSplitViewCoordinator.exploreSplitVC
            }
        self.exploreTab = exploreTab
        
        let assistantTab = UITab(title: "Assistant", image: SFSymbols.sparkles, identifier: "assistantTab") { _ in
                return assistantCoordinator.navigationController
            }
        tabBarController.tabs = [homeTab, exploreTab, assistantTab]
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension MainCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorDidRequestNavigationToExploreTab(for film: Film) {
        guard let exploreSplitViewCoordinator = self.exploreSplitViewCoordinator,
              let exploreTab = self.exploreTab else { return }
        tabBarController.selectedTab = exploreTab
        exploreSplitViewCoordinator.didSelectFilm(film)
    }
}
