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
    
    @Test func tabBar_hasSplitViewController() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        #expect(splitVC != nil, "Split view controller should not be nil.")
    }
    
    @Test func splitViewController_hasNavigationController() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        #expect(splitVC?.viewControllers.first is UINavigationController, "Split view controller should have a navigation controller.")
    }
    
    @Test func viewDidLoad_setsSingleExploreTab() {
        let sut = makeSUT()
        #expect(sut.viewControllers?.count == 1, "There should be one tab.")
    }
    
    @Test func exploreTab_isConfiguredAsDoubleColumnSplitView() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        #expect(splitVC?.preferredDisplayMode == .oneBesideSecondary, "Should be one beside secondary.")
        #expect(splitVC?.style == .doubleColumn, "Should be double column.")
    }
    
    @Test func exploreTabPrimaryColumn_containsExploreListVC() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        let navController = splitVC?.viewController(for: .primary) as? UINavigationController
        let rootVC = navController?.viewControllers.first as? ExploreListVC
        #expect(rootVC != nil, "The primary column should contain an ExploreListVC.")
    }
    
    @Test func exploreTabSecondaryColumn_containsExploreDetailVC() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        let navController = splitVC?.viewController(for: .secondary) as? UINavigationController
        let detailVC = navController?.viewControllers.first as? ExploreDetailVC
        #expect(detailVC != nil, "The secondary column should contain an ExploreDetailVC.")
    }
    
    @Test func initialSelectedTab_isZero() {
        let sut = makeSUT()
        #expect(sut.viewControllers?.first?.tabBarItem.tag == 0, "Explore should be the selected tab on init.")
    }
    
    @Test func exploreTabTitle_isCorrect() {
        let sut = makeSUT()
        let title = sut.tabBar.items?[0].title
        #expect(title == "Explore", "`Explore` should be the first tab title.")
    }
    
    @Test func collapseSecondaryVC_forCompactWidth() {
        let sut = makeSUT()
        let result = sut.topColumnForCollapsing(secondaryRootVC: ExploreDetailVC())
        #expect(result == .primary, "For compact widths the secondary view controller should be collapsed.")
    }
    
    // MARK: - Helper method
    private func makeSUT() -> TabBarController {
        let sut = TabBarController()
        sut.loadViewIfNeeded()
        return sut
    }
}
