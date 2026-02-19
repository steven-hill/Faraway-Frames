//
//  ExploreListVCUITests.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 18/02/2026.
//

import XCTest

final class ExploreListVCUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_exploreListVC_hasTitle() {
        let title = app.staticTexts["Explore"]
        XCTAssertTrue(title.exists, "Should have a title.")
    }
    
    func test_exploreListVC_titleTransitionsToInlineOnScrollOnIphoneOnly() {
        let title = app.staticTexts["Explore"]
        let initialY = title.frame.origin.y

        let collectionView = app.collectionViews.element
        collectionView.swipeUp()
        let finalY = title.frame.origin.y
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            XCTAssertLessThan(finalY, initialY, "The title should move up into the navigation bar on iPhone.")
        } else {
            XCTAssertEqual(finalY, initialY, "The title should remain unchanged on iPad.")
        }
    }
}
