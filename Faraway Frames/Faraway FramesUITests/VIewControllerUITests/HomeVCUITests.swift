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
        guard CurrentDevice.isIPhone else {
            throw XCTSkip("iPhone-only test")
        }
        
        let title = app.staticTexts["Home"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
    }
    
    func test_homeVC_hasSegmentedControl_withCorrectSetup_andTapChangesSelection() {
        let segmentedControl = app.segmentedControls.element
        let numberOfSegments = segmentedControl.buttons.count
        
        XCTAssertTrue(segmentedControl.exists, "Should exist.")
        XCTAssertTrue(segmentedControl.isHittable, "Should be hittable.")
        XCTAssertTrue(numberOfSegments == 2, "Should have two segments.")
        XCTAssertTrue(segmentedControl.buttons["Up Next"].isSelected, "Should be selected by default.")
        XCTAssertFalse(segmentedControl.buttons["Watched"].isSelected, "Should not be selected by default.")
        
        segmentedControl.buttons["Watched"].tap()
        XCTAssertFalse(segmentedControl.buttons["Up Next"].isSelected, "Should not be selected now.")
        XCTAssertTrue(segmentedControl.buttons["Watched"].isSelected, "Should be selected now.")
    }

    func test_homeVC_hasCollectionView() {
        let collectionView = app.collectionViews.element
        
        XCTAssertTrue(collectionView.exists, "Should exist.")
    }
    
    func test_homeVC_whenNoFilmsAreInDatabase_showEmptyStateView() {
        let emptyStateView = app.staticTexts["HomeVC_EmptyStateView"]
        
        XCTAssertTrue(emptyStateView.exists, "Should exist.")
    }
}
