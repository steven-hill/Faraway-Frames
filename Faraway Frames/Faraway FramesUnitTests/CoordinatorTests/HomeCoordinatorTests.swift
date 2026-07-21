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
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = HomeCoordinator(navigationController: UINavigationController(),
                                  context: testPersistenceController.viewContext,
                                  imageLoader: MockImageLoader(),
                                  filmQueueService: filmQueueService
        )

        sut.start()
        
        #expect(sut.navigationController.viewControllers.count == 1, "Should push 1 view controller onto the navigation stack.")
        #expect(sut.navigationController.viewControllers.first is HomeVC, "Should be `HomeVC`.")
    }
    
    final class HomeCoordinatorDelegateSpy: HomeCoordinatorDelegate {
        var didRequestNavigationCallCount = 0
        var capturedFilm: Film?
        
        func homeCoordinatorDidRequestNavigationToExploreTab(for film: Film) {
            didRequestNavigationCallCount = 1
            capturedFilm = film
        }
    }

    @Test("HomeCoordinator forwards the selection event's film up to delegate")
    func homeCoordinator_homeViewModelDidSelectFilm_bubblesEventUpToDelegate() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = HomeCoordinator(navigationController: UINavigationController(),
                                  context: testPersistenceController.viewContext,
                                  imageLoader: MockImageLoader(),
                                  filmQueueService: filmQueueService
        )
        let delegateSpy = HomeCoordinatorDelegateSpy()
        sut.delegate = delegateSpy
        let film = Film.sample[0]
        
        sut.homeViewModelDidCaptureFilm(film)
        
        #expect(delegateSpy.didRequestNavigationCallCount == 0, "Should have called delegate method once.")
        #expect(delegateSpy.capturedFilm?.title == "Batman", "Should match the film passed to delegate method.")
    }
}
