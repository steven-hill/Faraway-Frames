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
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_assistantVC_isPresentedOnExploreTab() {
        launchAppAndNavigateToFilmsList()
        goToExploreDetailVCAndTapOnMoreLikeThisButton()
        
        let title = app.staticTexts["Assistant"]
        let closeButton = app.buttons["AssistantVC_CloseButton"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
        XCTAssertTrue(closeButton.isHittable, "Should have a hittable close button.")
    }
    
    func test_assistantVC_isPresentedOnHomeTab() {
        launchAppWithPersistedDataOnHomeTab()
        goToExploreDetailVCAndTapOnMoreLikeThisButton()
        
        let title = app.staticTexts["Assistant"]
        let closeButton = app.buttons["AssistantVC_CloseButton"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
        XCTAssertTrue(closeButton.isHittable, "Should have a hittable close button.")
    }
    
    // MARK: - Helper methods
    private func launchAppAndNavigateToFilmsList() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockNetworkSuccess"]
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    private func launchAppWithPersistedDataOnHomeTab() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockPersistenceData"]
        app.launch()
    }
    
    private func goToExploreDetailVCAndTapOnMoreLikeThisButton() {
        app.collectionViews.element.cells.element(boundBy: 0).tap()
        app.swipeUp()
        let moreLikeThisButton = app.buttons["ExploreDetailVC_MoreLikeThisButton"]
        moreLikeThisButton.tap()
    }
}
