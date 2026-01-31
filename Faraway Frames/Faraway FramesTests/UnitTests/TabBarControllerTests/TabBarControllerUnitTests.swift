//
//  TabBarControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 06/01/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct TabBarControllerUnitTests {
    
    @Test func tabBarController_hasSplitViewController() {
        let sut = makeSUT()
        let splitVC = sut.tabs.first?.viewController as? UISplitViewController
        
        #expect(splitVC != nil, "Should not be nil.")
    }
    
    @Test func tabBarController_splitViewController_hasNavigationController() {
        let sut = makeSUT()
        let splitVC = sut.tabs.first?.viewController as? UISplitViewController
        
        #expect(splitVC?.viewControllers.first is UINavigationController, "Split view controller should have a navigation controller.")
    }
    
    @Test func tabBarController_viewDidLoad_setsOneTab() {
        let sut = makeSUT()
        #expect(sut.tabs.count == 1, "There should be one tab.")
    }
    
    @Test func tabBarController_exploreTab_isConfiguredAsDoubleColumnSplitView() {
        let sut = makeSUT()
        let splitVC = sut.tabs.first?.viewController as? UISplitViewController
        
        #expect(splitVC?.preferredDisplayMode == .oneBesideSecondary, "Should be `one beside secondary`.")
        #expect(splitVC?.style == .doubleColumn, "Should be double column.")
    }
    
    @Test func tabBarController_exploreTabPrimaryColumn_vcIsNotNil() {
        let sut = makeSUT()
        let splitVC = sut.tabs.first?.viewController as? UISplitViewController
        let navController = splitVC?.viewController(for: .primary) as? UINavigationController
        
        let rootVC = navController?.viewControllers.first as? ExploreListVC
        
        #expect(rootVC != nil, "Should not be nil.")
    }
    
    @Test func tabBarController_exploreTabSecondaryColumn_vcIsNotNil() {
        let sut = makeSUT()
        let splitVC = sut.tabs.first?.viewController as? UISplitViewController
        let navController = splitVC?.viewController(for: .secondary) as? UINavigationController
        
        let detailVC = navController?.viewControllers.first as? ExploreDetailVC
        
        #expect(detailVC != nil, "Should not be nil.")
    }
    
    @Test func tabBarController_exploreTabIdentifer_isCorrect() {
        let sut = makeSUT()
        #expect(sut.tabs.first?.identifier == "exploreTab", "Identifier should be 'exploreTab`.")
    }
    
    @Test func tabBarController_exploreTabTitle_isCorrect() {
        let sut = makeSUT()
        
        let title = sut.tabs.first?.title
        
        #expect(title == "Explore", "`Explore` should be the first tab's title.")
    }
    
    @Test func tabBarController_splitVC_returnsCorrectColumnFromDelegate() {
        let sut = makeSUT()
        let splitVC = sut.tabs.first?.viewController as! UISplitViewController
        let detailNav = UINavigationController(rootViewController: ExploreDetailVC())
        splitVC.setViewController(detailNav, for: .secondary)
        
        let result = sut.splitViewController(splitVC, topColumnForCollapsingToProposedTopColumn: .primary)
        
        #expect(result == .primary, "Should display the primary column after the split view interface collapses.")
    }
    
    // MARK: - Helper method
    private func makeSUT() -> TabBarController {
        let sut = TabBarController()
        sut.loadViewIfNeeded()
        return sut
    }
}
