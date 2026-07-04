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
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_exploreDetailVC_whenNoFilmIsSelected_displaysMessageAndHidesButtons() throws {
        guard CurrentDevice.isIPad else {
            throw XCTSkip("iPad-only test")
        }
        
        launchAppAndNavigateToFilmDetails()
        
        XCTAssertTrue(app.staticTexts["No Film Selected"].isHittable, "Should show a message.")
        XCTAssertTrue(app.staticTexts["Select a film from the list for more details."].isHittable, "Should show a message.")
        XCTAssertFalse(app.buttons["ExploreDetailVC_UpNextButton"].exists, "Should be hidden.")
        XCTAssertFalse(app.buttons["ExploreDetailVC_WatchedButton"].exists, "Should be hidden.")
        XCTAssertFalse(app.buttons["ExploreDetailVC_MoreLikeThisButton"].exists, "Should be hidden.")
    }
    
    func test_exploreDetailVC_hasAllUIElements() {
        launchAppAndNavigateToFilmDetails()
        
        tapFirstCollectionViewCell()
        
        assertExploreDetailElementsExist()
    }
    
    func test_exploreDetailVC_hasAllUIElementsAfterDeviceRotation() {
        launchAppAndNavigateToFilmDetails()
        
        tapFirstCollectionViewCell()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        assertExploreDetailElementsExist()
        
        XCUIDevice.shared.orientation = .landscapeRight
        assertExploreDetailElementsExist()
    }
    
    func test_exploreDetailVC_buttonsAreHittable() {
        launchAppAndNavigateToFilmDetails()
        tapFirstCollectionViewCell()
        
        app.swipeUp()
        
        XCTAssertTrue(app.buttons["ExploreDetailVC_UpNextButton"].isHittable, "Should be hittable.")
        XCTAssertTrue(app.buttons["ExploreDetailVC_WatchedButton"].isHittable, "Should be hittable.")
        XCTAssertTrue(app.buttons["ExploreDetailVC_MoreLikeThisButton"].isHittable, "Should be hittable.")
    }
    
    func test_exploreDetailVC_upNextButton_whenTapped_togglesTitle() {
        launchAppWithPersistenceData()
        revealButtons()
        
        let upNextButton = app.buttons["ExploreDetailVC_UpNextButton"]
        let result = makeResult(for: upNextButton, buttonLabel: "Remove from Up Next")
        XCTAssertEqual(result, .completed, "The button label did not load from Core Data in time.")
        
        upNextButton.tap()

        let changedResult = makeResult(for: upNextButton, buttonLabel: "Add to Up Next")
        XCTAssertEqual(changedResult, .completed, "The button label did not change to 'Add to Up Next' after tap.")
    }
    
    func test_exploreDetailVC_watchedButton_whenTapped_togglesTitle() {
        launchAppWithPersistenceData()
        revealButtons()
        
        let watchedButton = app.buttons["ExploreDetailVC_WatchedButton"]
        let result = makeResult(for: watchedButton, buttonLabel: "Add to Watched")
        XCTAssertEqual(result, .completed, "The button label did not load from Core Data in time.")
        
        watchedButton.tap()
        
        let changedResult = makeResult(for: watchedButton, buttonLabel: "Remove from Watched")
        XCTAssertEqual(changedResult, .completed, "The button label did not change to 'Remove from Watched' after tap.")
    }
    
    func test_exploreDetailVC_whenAddingFilmButDiskIsFull_showsCorrectErrorMessage() {
        app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
        app.launch(with: .addDiskFull)
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    // MARK: - Helper methods
    private func launchAppAndNavigateToFilmDetails() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockNetworkSuccess"]
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    private func launchAppWithPersistenceData() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockNetworkSuccess",
                               "-UITestingMockPersistenceData"]
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    private func revealButtons() {
        NavigationHelper.navigateToExploreTab(app: app)
        tapFirstCollectionViewCell()
        app.swipeUp()
    }
    
    private func makeResult(for button: XCUIElement, buttonLabel: String) -> XCTWaiter.Result {
        let predicate = NSPredicate(format: "label == %@", buttonLabel)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: button)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5.0)
        return result
    }
    
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
