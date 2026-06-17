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
    private let context: NSManagedObjectContext
    private let filmQueueService: FilmQueueService
    
    init(navigationController: UINavigationController, context: NSManagedObjectContext, filmQueueService: FilmQueueService) {
        self.navigationController = navigationController
        self.context = context
        self.filmQueueService = filmQueueService
    }
    
    func start() {
        let upNextRequest = FilmMO.upNextFetchRequest()
        let upNextFRC = NSFetchedResultsController(
            fetchRequest: upNextRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let watchedRequest = FilmMO.watchedFetchRequest()
        let watchedFRC = NSFetchedResultsController(
            fetchRequest: watchedRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let homeViewModel = HomeViewModel(
            context: context,
            upNextFRC: upNextFRC,
            watchedFRC: watchedFRC,
            filmQueueService: filmQueueService
        )
        
        let homeVC = HomeVC(homeViewModel: homeViewModel)
        navigationController.setViewControllers([homeVC], animated: false)
    }
}
