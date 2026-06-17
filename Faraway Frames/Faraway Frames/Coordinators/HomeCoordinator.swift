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
        let homeViewModel = HomeViewModel(context: context)
        let homeVC = HomeVC(homeViewModel: homeViewModel)
        navigationController.setViewControllers([homeVC], animated: false)
    }
}
