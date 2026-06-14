//
//  ExploreDetailVCUITests.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 22/02/2026.
//

import XCTest

final class ExploreDetailVCUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-UITestingMockNetworkSuccess"]
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_exploreDetailVC_whenNoFilmIsSelected_displaysMessageAndHidesButtons() throws {
        guard CurrentDevice.isIPad else {
            throw XCTSkip("iPad-only test")
        }
        
        NavigationHelper.navigateToExploreTab(app: app)
        
        XCTAssertTrue(app.staticTexts["No Film Selected"].isHittable, "Should show a message.")
        XCTAssertTrue(app.staticTexts["Select a film from the list for more details."].isHittable, "Should show a message.")
        XCTAssertFalse(app.buttons["ExploreDetailVC_UpNextButton"].exists, "Should be hidden.")
        XCTAssertFalse(app.buttons["ExploreDetailVC_WatchedButton"].exists, "Should be hidden.")
        XCTAssertFalse(app.buttons["ExploreDetailVC_MoreLikeThisButton"].exists, "Should be hidden.")
    }
    
    func test_exploreDetailVC_hasAllUIElements() {
        NavigationHelper.navigateToExploreTab(app: app)
        
        tapFirstCollectionViewCell()
        
        assertExploreDetailElementsExist()
    }
    
    func test_exploreDetailVC_hasAllUIElementsAfterDeviceRotation() {
        NavigationHelper.navigateToExploreTab(app: app)
        
        tapFirstCollectionViewCell()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        assertExploreDetailElementsExist()
        
        XCUIDevice.shared.orientation = .landscapeRight
        assertExploreDetailElementsExist()
    }
    
    func test_exploreDetailVC_buttonsAreHittable() {
        NavigationHelper.navigateToExploreTab(app: app)
        tapFirstCollectionViewCell()
        
        app.swipeUp()
        
        XCTAssertTrue(app.buttons["ExploreDetailVC_UpNextButton"].isHittable, "Should be hittable.")
        XCTAssertTrue(app.buttons["ExploreDetailVC_WatchedButton"].isHittable, "Should be hittable.")
        XCTAssertTrue(app.buttons["ExploreDetailVC_MoreLikeThisButton"].isHittable, "Should be hittable.")
    }
    
    // MARK: - Helper methods
    private func assertExploreDetailElementsExist() {
        let elements = [
            app.images["ExploreDetailVC_MovieBanner"],
            app.staticTexts["ExploreDetailVC_TitleLabel"],
            app.staticTexts["ExploreDetailVC_OriginalTitlesLabel"],
            app.staticTexts["ExploreDetailVC_ReleaseDateAndRunningTimeLabel"],
            app.staticTexts["ExploreDetailVC_RottenTomatoesScoreLabel"],
            app.staticTexts["ExploreDetailVC_SynopsisHeaderLabel"],
            app.staticTexts["ExploreDetailVC_SynopsisLabel"],
            app.otherElements["ExploreDetailVC_CreditsContainer"],
            app.buttons["ExploreDetailVC_UpNextButton"],
            app.buttons["ExploreDetailVC_WatchedButton"],
            app.buttons["ExploreDetailVC_MoreLikeThisButton"]
        ]
        
        for element in elements {
            XCTAssertTrue(element.exists, "\(element) should exist.")
        }
    }
    
    private func tapFirstCollectionViewCell() {
        app.collectionViews.element.cells.element(boundBy: 0).tap()
    }
}
