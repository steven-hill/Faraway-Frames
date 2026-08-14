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
    
    @Test func mainCoordinator_start_createsCorrectNumberOfTabs() throws {
        let (sut, _) = try makeSUT()
        
        sut.start()
        
        #expect(sut.tabBarController.tabs.count == 2, "Should be two tabs.")
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
