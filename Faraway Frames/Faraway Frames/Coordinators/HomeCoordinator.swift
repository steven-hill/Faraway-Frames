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
    private let imageLoader: ImageLoader
    private let filmQueueService: FilmQueueService
    private let frcFactory: FRCFactory
    
    init(navigationController: UINavigationController,
         context: NSManagedObjectContext,
         imageLoader: ImageLoader,
         filmQueueService: FilmQueueService,
         frcFactory: FRCFactory) {
        self.navigationController = navigationController
        self.context = context
        self.imageLoader = imageLoader
        self.filmQueueService = filmQueueService
        self.frcFactory = frcFactory
    }
    
    func start() {
        let upNextFRC = frcFactory.makeHomeUpNextFRC(context: context)
        let watchedFRC = frcFactory.makeHomeWatchedFRC(context: context)
        
        let homeViewModel = HomeViewModel(
            upNextFRC: upNextFRC,
            watchedFRC: watchedFRC,
            imageLoader: imageLoader,
            filmQueueService: filmQueueService
        )
        homeViewModel.coordinatorDelegate = self
        let homeVC = HomeVC(homeViewModel: homeViewModel)
        navigationController.setViewControllers([homeVC], animated: false)
    }
}

extension HomeCoordinator: HomeViewModelCoordinatorDelegate {
    func homeViewModelDidCaptureFilm(_ film: Film) {
        let filmDetailViewModel = FilmDetailViewModel(film: film,
                                                      imageLoader: imageLoader,
                                                      managedObjectContext: context,
                                                      frcFactory: frcFactory,
                                                      filmQueueService: filmQueueService
        )
        let detailVC = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
