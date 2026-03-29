//
//  HomeVCUITests.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 29/03/2026.
//

import XCTest

final class HomeVCUITests: XCTestCase {
    
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
    
    func test_homeVC_hasTitle() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("iPhone-only test")
        }
        
        let title = app.staticTexts["Home"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
    }

    func test_homeVC_hasCollectionView() {
        let collectionView = app.collectionViews.element
        
        XCTAssertTrue(collectionView.exists, "Should exist.")
    }
}
