//
//  HomeCoordinatorTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 22/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct HomeCoordinatorTests {
    
    @Test func homeCoordinator_start_placesViewControllerOnNavigationStack() {
        let sut = makeSUT()

        sut.start()
        
        #expect(sut.navigationController.viewControllers.count == 1, "Should push 1 view controller onto the navigation stack.")
        #expect(sut.navigationController.viewControllers.first is HomeVC, "Should be `HomeVC`.")
    }
    
    @Test("Sets Home View Model's coordinator delegate to self.")
    func homeCoordinator_start_setsHomeViewModelsCoordinatorDelegate() {
        let sut = makeSUT()
        
        sut.start()
        let homeVC = sut.navigationController.viewControllers.first as! HomeVC
        
        #expect(homeVC.homeViewModel.coordinatorDelegate != nil, "Should be set.")
    }

    @Test("HomeCoordinator pushes `ExploreDetailVC` onto navigation stack after delegate method passes over a film")
    func homeCoordinator_homeViewModelDidCaptureFilm_displaysCorrectViewControllerWithFilm() {
        let sut = makeSUT()
        sut.start()
        let film = Film.sample[0]

        sut.homeViewModelDidCaptureFilm(film)
        guard let detailVC = sut.navigationController.topViewController as? ExploreDetailVC else {
            Issue.record("Expected to push an `ExploreDetailVC` onto the navigation stack.")
            return
        }
        detailVC.view.layoutIfNeeded()
        
        #expect(sut.navigationController.viewControllers.count == 2, "Should be two view controllers on the navigation stack.")
        #expect(detailVC.updatedFilm?.id == film.id, "Should match the film passed to delegate method.")
    }
    
    // MARK: - SUT Helper Method
    private func makeSUT() -> HomeCoordinator {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = HomeCoordinator(navigationController: UINavigationController(),
                                  context: testPersistenceController.viewContext,
                                  imageLoader: MockImageLoader(),
                                  filmQueueService: filmQueueService,
                                  frcFactory: MockFRCFactory()
        )
        return sut
    }
}
