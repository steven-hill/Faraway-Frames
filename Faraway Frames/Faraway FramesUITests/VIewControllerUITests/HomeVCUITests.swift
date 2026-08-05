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
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        app = nil
    }
    
    func test_homeVC_hasTitle() throws {
        launchApp()
        guard CurrentDevice.isIPhone else {
            throw XCTSkip("iPhone-only test")
        }
        
        let title = app.staticTexts["Home"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
    }
    
    func test_homeVC_hasSegmentedControl_withCorrectSetup_andTapChangesSelection() {
        launchApp()
        let segmentedControl = app.segmentedControls["HomeVC_Segmented_Control"]
        let numberOfSegments = segmentedControl.buttons.count
        
        XCTAssertTrue(segmentedControl.exists, "Should exist.")
        XCTAssertTrue(segmentedControl.isHittable, "Should be hittable.")
        XCTAssertTrue(numberOfSegments == 2, "Should have two segments.")
        
        let upNextSegment = segmentedControl.buttons.element(boundBy: 0)
        let watchedSegment = segmentedControl.buttons.element(boundBy: 1)
        XCTAssertTrue(upNextSegment.isSelected, "Should be selected by default.")
        
        watchedSegment.tap()
        XCTAssertTrue(watchedSegment.isSelected, "Should be selected now.")
    }
    
    func test_homeVC_segmentedControl_whenSelectedSegmentChangedAndDeviceRotatedToLandscape_bothSegmentsAreHittable() {
        launchApp()
        let segmentedControl = app.segmentedControls["HomeVC_Segmented_Control"]
        
        XCTAssertTrue(segmentedControl.isHittable, "Should be hittable.")
        
        let upNextSegment = segmentedControl.buttons.element(boundBy: 0)
        let watchedSegment = segmentedControl.buttons.element(boundBy: 1)
        
        watchedSegment.tap()
        XCTAssertTrue(watchedSegment.isSelected, "Should be selected now.")
        
        XCUIDevice.shared.orientation = .landscapeLeft
        
        upNextSegment.tap()
        XCTAssertTrue(upNextSegment.isSelected, "Should be selected now.")
    
        watchedSegment.tap()
        XCTAssertTrue(watchedSegment.isSelected, "Should be selected now.")
        
        upNextSegment.tap()
        XCTAssertTrue(upNextSegment.isSelected, "Should be selected now.")
        
        XCUIDevice.shared.orientation = .portrait
    }
    
    func test_homeVC_whenNoFilmsAreInDatabase_showsEmptyStateViewForBothSegments() {
        launchApp()
        let segmentedControl = app.segmentedControls["HomeVC_Segmented_Control"]
        let collectionView = app.collectionViews.element
        let emptyStateView = app.staticTexts["HomeVC_EmptyStateView"]
        XCTAssertTrue(collectionView.exists, "Should exist.")
        XCTAssertTrue(emptyStateView.exists, "Should exist.")
        
        let watchedSegment = segmentedControl.buttons.element(boundBy: 1)
        watchedSegment.tap()
        XCTAssertTrue(emptyStateView.exists, "Should exist.")
    }
    
    func test_homeVC_whenFetchingFilmFromDatabaseIsSuccessful_showsCellInCollectionView() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockPersistenceData"]
        app.launch()

        let collectionView = app.collectionViews.element
        
        XCTAssertTrue(collectionView.exists, "Should exist.")
        XCTAssertEqual(collectionView.cells.count, 1, "Should have one cell (one film in database).")
        XCTAssertTrue(collectionView.cells.firstMatch.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(collectionView.cells.images["Film_Grid_Cell_Poster"].exists, "Cells should have an image.")
        XCTAssertTrue(collectionView.cells.buttons["Film_Grid_Cell_Title"].exists, "Cells should have a text label.")
    }
    
    func test_homeVC_whenFetchingFilmsFromDatabaseResultsInError_showsAlert() {
        app = XCUIApplication()
        app.launch(with: .fetchFromDatabaseError)
        
        let alert = app.alerts.firstMatch
        let button = alert.buttons.firstMatch

        XCTAssertTrue(alert.exists, "Should exist.")
        XCTAssertTrue(alert.staticTexts.count == 2, "Should have 2 static texts.")
        XCTAssertTrue(button.exists, "Should exist.")
        XCTAssertTrue(button.isHittable, "Should be able to be tapped.")
    }
    
    // MARK: - Helper method
    private func launchApp() {
        app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
        app.launchArguments.append("-UITesting")
        app.launch()
    }
}
