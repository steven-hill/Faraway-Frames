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
struct TabBarControllerTests {

    @Test func tab_Bar_Has_NavigationController() {
        let sut = makeSUT()
        let navController = sut.viewControllers?.first as? UINavigationController
        #expect(navController != nil, "Navigation controller should not be nil.")
    }
    
    @Test func tab_Bar_Has_One_View_Controller() {
        let sut = makeSUT()
        #expect(sut.viewControllers?.count == 1, "There should be one view controller in the tab bar.")
    }
    
    @Test func initial_Selected_Tab_Is_Zero() {
        let sut = makeSUT()
        #expect(sut.viewControllers?.first?.tabBarItem.tag == 0, "Explore should be the selected tab on init.")
    }
    
    @Test func first_Tab_Is_Explore() {
        let sut = makeSUT()
        let navController = sut.viewControllers?.first as? UINavigationController
        #expect(navController?.viewControllers.first is ExploreVC, "`ExploreVC` should be the first VC on the tab bar.")
    }
    
    @Test func tab_Bar_Title_Is_Correct() {
        let sut = makeSUT()
        let title = sut.tabBar.items?[0].title
        #expect(title == "Explore", "`Explore` should be the first tab title.")
    }
    
    func makeSUT() -> TabBarController {
        let sut = TabBarController()
        sut.loadViewIfNeeded()
        return sut
    }
}
