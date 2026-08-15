//
//  AssistantVCUITests.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 20/03/2026.
//

import XCTest

final class AssistantVCUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_assistantVC_hasTitle() {
        NavigationHelper.navigateToExploreTab(app: app)
        app.collectionViews.element.cells.element(boundBy: 0).tap()
        app.swipeUp()
        let moreLikeThisButton = app.buttons["ExploreDetailVC_MoreLikeThisButton"]
        moreLikeThisButton.tap()
        let title = app.staticTexts["Assistant"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
    }
}
