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

    @Test("HomeCoordinator forwards film from home view model up to delegate")
    func homeCoordinator_homeViewModelDidCaptureFilm_bubblesEventUpToDelegate() {
        let sut = makeSUT()
        let delegateSpy = HomeCoordinatorDelegateSpy()
        sut.delegate = delegateSpy
        let film = Film.sample[0]
        
        sut.homeViewModelDidCaptureFilm(film)
        
        #expect(delegateSpy.didRequestNavigationCallCount == 1, "Should have called delegate method once.")
        #expect(delegateSpy.capturedFilm?.id == film.id, "Should match the film passed to delegate method.")
    }
    
    // MARK: - SUT Helper Method
    private func makeSUT() -> HomeCoordinator {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = HomeCoordinator(navigationController: UINavigationController(),
                                  context: testPersistenceController.viewContext,
                                  imageLoader: MockImageLoader(),
                                  filmQueueService: filmQueueService
        )
        return sut
    }
    
    // MARK: - Home Coordinator Delegate Spy
    final class HomeCoordinatorDelegateSpy: HomeCoordinatorDelegate {
        var didRequestNavigationCallCount = 0
        var capturedFilm: Film?
        
        func homeCoordinatorDidRequestNavigationToExploreTab(for film: Film) {
            didRequestNavigationCallCount = 1
            capturedFilm = film
        }
    }
}
