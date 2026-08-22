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
    private let frcFactory: HomeFRCFactory & FilmDetailFRCFactory
    private let foundationModelsClient: FoundationModelsService
    
    init(navigationController: UINavigationController,
         context: NSManagedObjectContext,
         imageLoader: ImageLoader,
         filmQueueService: FilmQueueService,
         frcFactory: HomeFRCFactory & FilmDetailFRCFactory,
         foundationModelsClient: FoundationModelsService) {
        self.navigationController = navigationController
        self.context = context
        self.imageLoader = imageLoader
        self.filmQueueService = filmQueueService
        self.frcFactory = frcFactory
        self.foundationModelsClient = foundationModelsClient
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
        let filmDetailViewModel = FilmDetailViewModel(imageLoader: imageLoader,
                                                      managedObjectContext: context,
                                                      frcFactory: frcFactory,
                                                      filmQueueService: filmQueueService
        )
        let detailVC = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        detailVC.navigationDelegate = self
        navigationController.pushViewController(detailVC, animated: true)
    }
}

extension HomeCoordinator: ExploreDetailNavigationDelegate {
    func exploreDetailDidTapMoreLikeThisButton() {
        let assistantViewModel = AssistantViewModel(foundationModelsClient: foundationModelsClient)
        let assistantVC = AssistantVC(assistantViewModel: assistantViewModel)
        let navController = UINavigationController(rootViewController: assistantVC)
        navigationController.present(navController, animated: true)
    }
}
