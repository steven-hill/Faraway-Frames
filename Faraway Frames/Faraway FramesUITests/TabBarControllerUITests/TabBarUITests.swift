//
//  TabBarUITests.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 21/02/2026.
//

import XCTest

final class TabBarUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launchArguments.append("-UITestingMockNetworkSuccess")
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_tabBar_whenLoaded_existsAndIsHittable() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("iPhone-only test")
        }
        
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Should exist.")
        XCTAssertTrue(app.tabBars.firstMatch.isHittable, "Should be able to be tapped.")
    }
    
    func test_tabBarButtons_whenLoaded_existAndAreHittable() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("iPad-only test")
        }
        
        XCTAssertEqual(app.buttons.matching(identifier: "Explore").count, 2, "Should be 2.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 0).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 1).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 0).isHittable, "Should be able to be tapped.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 1).isHittable, "Should be able to be tapped.")
        XCTAssertFalse(app.buttons.matching(identifier: "Explore").element(boundBy: 2).exists, "Should not exist.")
        
        XCTAssertEqual(app.buttons.matching(identifier: "Assistant").count, 2, "Should be 2.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 0).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 1).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 0).isHittable, "Should be able to be tapped.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 1).isHittable, "Should be able to be tapped.")
    }
    
    func test_tabBar_hasCorrectNumberOfTabs() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("iPhone-only test")
        }
        let numberOfTabs = app.tabBars.firstMatch.buttons.count
        
        XCTAssertEqual(numberOfTabs, 2, "Should have two tabs.")
    }
    
    func test_tabBar_onInit_firstTabIsSelected() {
        let tab = app.buttons.matching(identifier: "Explore")
        
        XCTAssertTrue(tab.element.firstMatch.isSelected, "Should be selected.")
    }
    
    func test_tabBar_canNavigateBackFromExploreDetailVCToExploreListVC() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("iPhone-only test")
        }
        app.collectionViews.element.cells.element(boundBy: 0).tap()
        app.tabBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertTrue(app.searchFields["ExploreListVC_SearchBar_SearchField"].exists, "Should exist.")
    }
}
