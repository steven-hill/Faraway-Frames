//
//  MainCoordinatorTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 03/02/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct MainCoordinatorTests {
    
    @Test func mainCoordinator_childCoordinatorsIsEmpty_onInit() throws {
        let (sut, _) = try makeSUT()
        #expect(sut.childCoordinators.isEmpty, "Should be empty on init.")
    }
    
    @Test func mainCoordinator_start_createsHomeCoordinatorAsChildCoordinator() throws {
        let (sut, _) = try makeSUT()
        
        sut.start()
        
        let childCoordinator = sut.childCoordinators.first as? HomeCoordinator
        #expect(childCoordinator != nil, "Should not be nil.")
    }
    
    @Test func mainCoordinator_start_createsExploreSplitViewCoordinatorAsChildCoordinator() throws {
        let (sut, _) = try makeSUT()
        
        sut.start()
        
        let childCoordinator = sut.childCoordinators[1] as? ExploreSplitViewCoordinator
        #expect(childCoordinator != nil, "Should not be nil.")
    }
    
    @Test func mainCoordinator_start_createsAssistantCoordinatorAsChildCoordinator() throws {
        let (sut, _) = try makeSUT()
        
        sut.start()
        
        let childCoordinator = sut.childCoordinators[2] as? AssistantCoordinator
        #expect(childCoordinator != nil, "Should not be nil.")
    }
    
    @Test func mainCoordinator_start_createsThreeTabs() throws {
        let (sut, _) = try makeSUT()
        
        sut.start()
        
        #expect(sut.tabBarController.tabs.count == 3, "Should be three tabs.")
    }
    
    @Test func mainCoordinator_start_setsRootViewController() throws {
        let (sut, _) = try makeSUT()
        
        sut.start()
        
        #expect(sut.window.rootViewController != nil, "Should not be nil.")
        #expect(sut.window.rootViewController is UITabBarController, "Should be a UITabBarController.")
    }
    
    @Test func mainCoordinator_start_callsWindowMakeKeyAndVisible() throws {
        let (sut, window) = try makeSUT()
        
        sut.start()
        
        #expect(window.makeKeyAndVisibleCalled, "Should have called makeKeyAndVisible.")
    }

    final class ExploreNavigationDelegateSpy: ExploreNavigationDelegate {
        var shouldDeselectAfterSelection = false
        var didCallSelectFilmCallCount = 0
        var capturedFilm: Film?
        
        func didSelectFilm(_ film: Film) {
            didCallSelectFilmCallCount = 1
            capturedFilm = film
        }
    }

    @Test("MainCoordinator changes tab to `Explore`, and triggers the ExploreSplitViewCoordinator routing")
    func mainCoordinator_homeCoordinatorDidRequestNavigationToExploreTab_handlesCrossTabRelay() throws {
        let (sut, _) = try makeSUT()
        sut.start()
        let exploreSpy = ExploreNavigationDelegateSpy()
        sut.exploreSplitViewCoordinator = exploreSpy
        let film = Film.sample[0]
        
        sut.homeCoordinatorDidRequestNavigationToExploreTab(for: film)
        
        #expect(sut.tabBarController.selectedTab == sut.exploreTab, "Should change selected tab to `Explore`.")
        #expect(exploreSpy.didCallSelectFilmCallCount == 1, "Should have called method on `ExploreSplitViewCoordinator`.")
        #expect(exploreSpy.capturedFilm?.id == film.id)
    }
    
    // MARK: - Helper Method
    private func makeSUT() throws -> (sut: MainCoordinator, window: WindowSpy) {
        let mockContainer = MockContainer()
        let windowSpy = WindowSpy()
        let sut = MainCoordinator(window: windowSpy, dependencies: mockContainer, persistenceController: try mockContainer.makePersistenceController())
        return (sut, windowSpy)
    }
    
    // MARK: - Window Spy
    final class WindowSpy: WindowProtocol {
        var rootViewController: UIViewController?
        var makeKeyAndVisibleCalled = false
        
        func makeKeyAndVisible() {
            makeKeyAndVisibleCalled = true
        }
    }
}
