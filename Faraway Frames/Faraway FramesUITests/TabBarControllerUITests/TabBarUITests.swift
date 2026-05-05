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
        guard CurrentDevice.isPhone else {
            throw XCTSkip("iPhone-only test")
        }
        
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Should exist.")
        XCTAssertTrue(app.tabBars.firstMatch.isHittable, "Should be able to be tapped.")
    }
    
    func test_tabBarButtons_whenLoaded_existAndAreHittable() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("iPad-only test")
        }
        
        XCTAssertEqual(app.buttons.matching(identifier: "Home").count, 2, "Should be 2.")
        XCTAssertTrue(app.buttons.matching(identifier: "Home").element(boundBy: 0).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Home").element(boundBy: 1).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Home").element(boundBy: 0).isHittable, "Should be able to be tapped.")
        XCTAssertTrue(app.buttons.matching(identifier: "Home").element(boundBy: 1).isHittable, "Should be able to be tapped.")

        XCTAssertEqual(app.buttons.matching(identifier: "Explore").count, 2, "Should be 2.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 0).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 1).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 0).isHittable, "Should be able to be tapped.")
        XCTAssertTrue(app.buttons.matching(identifier: "Explore").element(boundBy: 1).isHittable, "Should be able to be tapped.")
        
        XCTAssertEqual(app.buttons.matching(identifier: "Assistant").count, 2, "Should be 2.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 0).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 1).exists, "Should exist.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 0).isHittable, "Should be able to be tapped.")
        XCTAssertTrue(app.buttons.matching(identifier: "Assistant").element(boundBy: 1).isHittable, "Should be able to be tapped.")
    }
    
    func test_tabBar_hasCorrectNumberOfTabs() throws {
        guard CurrentDevice.isPhone else {
            throw XCTSkip("iPhone-only test")
        }
        let numberOfTabs = app.tabBars.firstMatch.buttons.count
        
        XCTAssertEqual(numberOfTabs, 3, "Should have three tabs.")
    }
    
    func test_tabBar_onInit_homeTabIsSelected() {
        let tab = app.buttons.matching(identifier: "Home")
        
        XCTAssertTrue(tab.element.firstMatch.isSelected, "Home should be selected.")
    }
    
    func test_tabBar_canNavigatefromHomeToExploreAndBackToHome() throws {
        guard CurrentDevice.isPhone else {
            throw XCTSkip("iPhone-only test")
        }
        app.tabBars.buttons["Explore"].firstMatch.tap()
        XCTAssertTrue(app.searchFields["ExploreListVC_SearchBar_SearchField"].exists, "Should exist.")
        
        app.collectionViews.element.cells.element(boundBy: 0).tap()
        app.tabBars.buttons["Explore"].firstMatch.tap()
        XCTAssertTrue(app.searchFields["ExploreListVC_SearchBar_SearchField"].exists, "Should exist.")
        
        app.tabBars.buttons["Home"].firstMatch.tap()
        let title = app.staticTexts["Home"]
        XCTAssertTrue(title.exists, "Should exist.")
    }
    
    func test_tabBar_canNavigateFromExploreTabToAssistantTab() throws {
        guard CurrentDevice.isPhone else {
            throw XCTSkip("iPhone-only test")
        }
        app.tabBars.buttons["Assistant"].firstMatch.tap()
        let title = app.staticTexts["Assistant"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
    }
}
