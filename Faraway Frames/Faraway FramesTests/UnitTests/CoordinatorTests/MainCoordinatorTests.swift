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
    
    @Test func mainCoordinator_childCoordinatorsIsEmpty_onInit() {
        let (sut, _) = makeSUT()
        #expect(sut.childCoordinators.isEmpty, "Should be empty on init.")
    }
    
    @Test func mainCoordinator_start_createsExploreSplitViewCoordinatorAsChildCoordinator() {
        let (sut, _) = makeSUT()
        
        sut.start()
        
        let childCoordinator = sut.childCoordinators.first as? ExploreSplitViewCoordinator
        #expect(childCoordinator != nil, "Should not be nil.")
    }
    
    @Test func mainCoordinator_start_createsExploreTab() {
        let (sut, _) = makeSUT()
        
        sut.start()
        
        #expect(sut.tabBarController.tabs.count == 1, "Should be one.")
    }
    
    @Test func mainCoordinator_start_setsRootViewController() {
        let (sut, _) = makeSUT()
        
        sut.start()
        
        #expect(sut.window.rootViewController != nil, "Should not be nil.")
        #expect(sut.window.rootViewController is UITabBarController, "Should be a UITabBarController.")
    }
    
    @Test func mainCoordinator_start_callsWindowMakeKeyAndVisible() {
        let (sut, window) = makeSUT()
        
        sut.start()
        
        #expect(window.makeKeyAndVisibleCalled, "Should have called makeKeyAndVisible.")
    }
    
    // MARK: - Helper Method
    private func makeSUT() -> (sut: MainCoordinator, window: WindowSpy) {
        let mockContainer = MockContainer()
        let windowSpy = WindowSpy()
        let sut = MainCoordinator(window: windowSpy, dependencies: mockContainer)
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
