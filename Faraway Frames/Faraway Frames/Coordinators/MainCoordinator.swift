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
    typealias Dependencies = FilmsListServicing & ImageLoading & AccessibilityServicing & FoundationModelsServicing
    let dependencies: Dependencies
    let persistenceController: PersistenceControlling
    let tabBarController = TabBarController()
    let frcFactory = FRCFactory()
    
    init(window: WindowProtocol,
         dependencies: Dependencies,
         persistenceController: PersistenceControlling) {
        self.window = window
        self.dependencies = dependencies
        self.persistenceController = persistenceController
    }
    
    func start() {
        let managedObjectContext = persistenceController.viewContext
        let filmQueueService = FilmQueueService(context: managedObjectContext)
        let filmSyncService = FilmSyncService(context: managedObjectContext)
        let imageLoader = dependencies.makeImageLoader()
        let foundationModelsClient = dependencies.makeFoundationModelsService()
        
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController(),
                                              context: managedObjectContext,
                                              imageLoader: imageLoader,
                                              filmQueueService: filmQueueService,
                                              frcFactory: frcFactory,
                                              foundationModelsClient: foundationModelsClient)
        homeCoordinator.start()
        childCoordinators.append(homeCoordinator)
        
        let exploreSplitViewCoordinator = ExploreSplitViewCoordinator(dependencies: dependencies,
                                                                      imageLoader: imageLoader,
                                                                      context: managedObjectContext,
                                                                      filmQueueService: filmQueueService,
                                                                      filmSyncService: filmSyncService,
                                                                      frcFactory: frcFactory,
                                                                      foundationModelsClient: foundationModelsClient)
        exploreSplitViewCoordinator.start()
        childCoordinators.append(exploreSplitViewCoordinator)
        
        tabBarController.tabs = [
            UITab(title: "Home", image: SFSymbols.house, identifier: "homeTab") { _ in
                return homeCoordinator.navigationController
            },
            UITab(title: "Explore", image: SFSymbols.filmStack, identifier: "exploreTab") { _ in
                return exploreSplitViewCoordinator.exploreSplitVC
            }
        ]
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
