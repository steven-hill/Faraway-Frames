//
//  TabBarControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 06/01/2026.
//

import Testing
@testable import Faraway_Frames
internal import UIKit

@MainActor
struct TabBarControllerUnitTests {
    
    @Test func tab_Bar_Has_SplitViewController() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        #expect(splitVC != nil, "Split view controller should not be nil.")
    }
    
    @Test func splitViewController_Has_NavigationController() {
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
        #expect(splitVC?.preferredDisplayMode == .oneBesideSecondary)
        #expect(splitVC?.style == .doubleColumn)
    }
    
    @Test func exploreTab_primaryColumn_containsExploreList() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        let navController = splitVC?.viewController(for: .primary) as? UINavigationController
        let rootVC = navController?.viewControllers.first as? ExploreListVC
        #expect(rootVC != nil)
    }
    
    @Test func exploreTab_secondaryColumn_containsExploreDetail() {
        let sut = makeSUT()
        let splitVC = sut.viewControllers?.first as? UISplitViewController
        let navController = splitVC?.viewController(for: .secondary) as? UINavigationController
        let detailVC = navController?.viewControllers.first as? ExploreDetailVC
        #expect(detailVC != nil)
    }
    
    @Test func initial_Selected_Tab_Is_Zero() {
        let sut = makeSUT()
        #expect(sut.viewControllers?.first?.tabBarItem.tag == 0, "Explore should be the selected tab on init.")
    }
    
    @Test func exploreTab_Title_Is_Correct() {
        let sut = makeSUT()
        let title = sut.tabBar.items?[0].title
        #expect(title == "Explore", "`Explore` should be the first tab title.")
    }
    
    private func makeSUT() -> TabBarController {
        let sut = TabBarController()
        sut.loadViewIfNeeded()
        return sut
    }
}
