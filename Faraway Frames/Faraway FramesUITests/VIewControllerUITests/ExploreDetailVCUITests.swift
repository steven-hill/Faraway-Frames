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
        app.launchArguments.append("-UITesting")
        app.launchArguments.append("-UITestingMockNetworkSuccess")
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_exploreDetailVC_whenNoFilmIsSelected_displaysMessage() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("iPad-only test")
        }
        
        navigateToExploreTab()
        
        XCTAssertTrue(app.staticTexts["No Film Selected"].isHittable, "Should show a message.")
        XCTAssertTrue(app.staticTexts["Pick a film from the list to see the details."].isHittable, "Should show a message.")
    }
    
    func test_exploreDetailVC_hasAllUIElements() {
        navigateToExploreTab()
        
        tapFirstCollectionViewCell()
        
        assertExploreDetailElementsExist()
    }
    
    func test_exploreDetailVC_hasAllUIElementsAfterDeviceRotation() {
        navigateToExploreTab()
        
        tapFirstCollectionViewCell()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        assertExploreDetailElementsExist()
        
        XCUIDevice.shared.orientation = .landscapeRight
        assertExploreDetailElementsExist()
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
            app.otherElements["ExploreDetailVC_CreditsContainer"]
        ]
        
        for element in elements {
            XCTAssertTrue(element.exists, "\(element) should be onscreen.")
        }
    }
    
    private func navigateToExploreTab() {
        let exploreTab = app.buttons.matching(identifier: "Explore")
        exploreTab.element.firstMatch.tap()
    }
    
    private func tapFirstCollectionViewCell() {
        app.collectionViews.element.cells.element(boundBy: 0).tap()
    }
}
