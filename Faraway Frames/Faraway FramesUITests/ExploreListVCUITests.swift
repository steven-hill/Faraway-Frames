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
    
    func test_exploreListVC_title_transitionsToInlineOnScrollOnIphoneOnly() {
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
    
    func test_exploreListVC_displaysCollectionViewInContentState() {
        let collectionView = app.collectionViews.element
        
        XCTAssertTrue(collectionView.exists, "Should exist.")
        XCTAssertGreaterThan(collectionView.cells.count, 0, "Should be more than zero cells.")
        XCTAssertTrue(collectionView.cells.firstMatch.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(collectionView.cells.element(boundBy: 0).images.element.exists, "Should have an image.")
        XCTAssertFalse(collectionView.cells.element(boundBy: 0).label.isEmpty, "Should have a text label.")
    }
    
    func test_exploreListVC_canNavigateToFilmDetails() {
        let collectionView = app.collectionViews.element
        collectionView.cells.element(boundBy: 0).tap()
        
        let filmTitle = app.staticTexts["ExploreDetailVC_TitleLabel"]
        XCTAssertTrue(filmTitle.exists, "Tapping a cell should navigate to the detail view.")
    }
    
    func test_exploreListVC_searchTextField_initialState() {
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        
        XCTAssertTrue(searchTextField.exists, "Should exist.")
        XCTAssertTrue(searchTextField.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(searchTextField.isEnabled, "Should be enabled.")
        XCTAssertNotNil(searchTextField.placeholderValue, "Should have a placeholder.")
    }
    
    func test_exploreListVC_searchTextField_displaysACancelButton_whenSearching() {
        let searchTextField = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        
        XCTAssertTrue(searchTextField.buttons.element.firstMatch.exists, "Should exist.")
    }
    
    func test_exploreListVC_searchTextField_displaysTextTypedIntoItAndCanClearTextViaButton() {
        let searchTextField = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        XCTAssertEqual(searchTextField.value as! String, "Castle in the Sky", "Should show the text that was typed in.")
        
        searchTextField.buttons.element.firstMatch.tap()
        XCTAssertEqual(searchTextField.value as? String, searchTextField.placeholderValue, "Should revert to placeholder text.")
    }
    
    func test_exploreListVC_searchTextField_canAlsoClearTextViaDeleteKey() {
        let searchTextField = setUpSearchTextFieldAndEnterText("C")
        app.keys["delete"].firstMatch.tap()
        
        XCTAssertEqual(searchTextField.value as? String, searchTextField.placeholderValue, "Should revert to placeholder text.")
    }
    
    func test_exploreListVC_searchResultsAppearForValidSearchQuery() {
        _ = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        let collectionView = app.collectionViews.element
        
        XCTAssertEqual(collectionView.cells.count, 1, "Should have one film in search results.")
    }
    
    func test_exploreListVC_showsNoSearchResultsForInvalidSearchQuery() {
        _ = setUpSearchTextFieldAndEnterText("Invalid query")
        let collectionView = app.collectionViews.element
        
        XCTAssertFalse(collectionView.exists, "Collection view should be hidden.")
    }
    
    func test_exploreListVC_doesNotPerformSearchIfTextFieldIsEmpty() {
        _ = setUpSearchTextFieldAndEnterText("")
        
        XCTAssertFalse(app.buttons["Search"].firstMatch.isEnabled, "Should be disabled.")
    }
    
    func test_exploreListVC_on_iPadCanHideExploreListVCToRevealAllExploreDetailVC() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("iPad-only test")
        }
        let collectionView = app.collectionViews.element
        XCTAssertFalse(app.staticTexts["ExploreDetailVC_TitleLabel"].firstMatch.isHittable, "Should not be visible.")
        collectionView.cells.element(boundBy: 0).tap()
        
        app.navigationBars.buttons.firstMatch.tap()
        
        XCTAssertTrue(app.staticTexts["ExploreDetailVC_TitleLabel"].firstMatch.isHittable, "Should be visible.")
        XCTAssertFalse(collectionView.isHittable, "Should be off screen.")
    }
    
    // MARK: - Helper method
    private func setUpSearchTextFieldAndEnterText(_ text: String) -> XCUIElement {
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        searchTextField.tap()
        searchTextField.typeText(text)
        return searchTextField
    }
}
