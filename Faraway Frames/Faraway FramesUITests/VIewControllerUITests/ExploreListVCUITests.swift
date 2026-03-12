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
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_exploreListVC_hasTitle() {
        launchAppForNetworkSuccessCase()
        
        let title = app.staticTexts["Explore"]
        
        XCTAssertTrue(title.exists, "Should have a title.")
    }
    
    func test_exploreListVC_title_whenInPortrait_transitionsToInlineOnScroll() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("iPhone-only test")
        }
        XCUIDevice.shared.orientation = .portrait
        launchAppForNetworkSuccessCase()
        let title = app.staticTexts["Explore"]
        let initialY = title.frame.origin.y

        let collectionView = app.collectionViews.element
        collectionView.swipeUp()
        let finalY = title.frame.origin.y
        
        XCTAssertLessThan(finalY, initialY, "The title should move up into the navigation bar on iPhone.")
    }
    
    func test_exploreListVC_displaysCollectionViewInContentState() {
        launchAppForNetworkSuccessCase()
        
        let collectionView = app.collectionViews.element
        
        XCTAssertTrue(collectionView.exists, "Should exist.")
        XCTAssertGreaterThan(collectionView.cells.count, 0, "Should be more than zero cells.")
        XCTAssertTrue(collectionView.cells.firstMatch.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(collectionView.cells.element(boundBy: 0).images.element.exists, "Should have an image.")
        XCTAssertFalse(collectionView.cells.element(boundBy: 0).label.isEmpty, "Should have a text label.")
    }
    
    func test_exploreListVC_canNavigateThroughFilms() {
        launchAppForNetworkSuccessCase()
        
        XCTAssertFalse(app.staticTexts["ExploreDetailVC_TitleLabel"].firstMatch.isHittable, "Should not be visible.")
        let collectionView = app.collectionViews.element
        collectionView.cells.element(boundBy: 0).tap()
        
        XCTAssertTrue(app.staticTexts["ExploreDetailVC_TitleLabel"].firstMatch.isHittable, "Should be visible.")
        XCTAssertFalse(collectionView.isHittable, "Should be off screen.")
        
        app.navigationBars.buttons.firstMatch.tap()
        collectionView.cells.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["ExploreDetailVC_TitleLabel"].firstMatch.isHittable, "Should be visible.")
        XCTAssertFalse(collectionView.isHittable, "Should be off screen.")
    }
    
    func test_exploreListVC_whenNotConnectedToInternet_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .noInternetConnection)
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["The internet connection appears to be offline"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_whenNetworkRequestTimesOut_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .networkTimeout)
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Network request timed out"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_whenURLIsInvalid_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .invalidURL)
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Invalid URL"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_whenResponseIsInvalid_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .invalidResponse)
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Invalid response"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_whenServerReturns500Error_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .serverError(statusCode: 500))
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Server error with status code: 500"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_forDecodingError_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .decodingError)
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Failed to decode data"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_forUnknownError_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .unknown)
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Unknown error"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_searchTextField_initialState() {
        launchAppForNetworkSuccessCase()
        
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        
        XCTAssertTrue(searchTextField.exists, "Should exist.")
        XCTAssertTrue(searchTextField.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(searchTextField.isEnabled, "Should be enabled.")
        XCTAssertNotNil(searchTextField.placeholderValue, "Should have a placeholder.")
    }
    
    func test_exploreListVC_searchTextField_displaysACancelButton_whenSearching() {
        launchAppForNetworkSuccessCase()
        
        let searchTextField = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        
        XCTAssertTrue(searchTextField.buttons.element.firstMatch.exists, "Should exist.")
    }
    
    func test_exploreListVC_searchTextField_displaysTextTypedIntoItAndCanClearTextViaButton() {
        launchAppForNetworkSuccessCase()
        
        let searchTextField = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        XCTAssertEqual(searchTextField.value as! String, "Castle in the Sky", "Should show the text that was typed in.")
        
        searchTextField.buttons.element.firstMatch.tap()
        XCTAssertEqual(searchTextField.value as? String, searchTextField.placeholderValue, "Should revert to placeholder text.")
    }
    
    func test_exploreListVC_searchTextField_canAlsoClearTextViaDeleteKey() {
        launchAppForNetworkSuccessCase()
        
        let searchTextField = setUpSearchTextFieldAndEnterText("C")
        app.keys["delete"].firstMatch.tap()
        
        XCTAssertEqual(searchTextField.value as? String, searchTextField.placeholderValue, "Should revert to placeholder text.")
    }
    
    func test_exploreListVC_searchResultsAppearForValidSearchQuery() {
        launchAppForNetworkSuccessCase()
        
        _ = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        let collectionView = app.collectionViews.element
        
        XCTAssertEqual(collectionView.cells.count, 1, "Should have one film in search results.")
    }
    
    func test_exploreListVC_showsNoSearchResultsForInvalidSearchQuery() {
        launchAppForNetworkSuccessCase()
        
        _ = setUpSearchTextFieldAndEnterText("Invalid query")
        let collectionView = app.collectionViews.element
        
        XCTAssertFalse(collectionView.exists, "Collection view should be hidden.")
    }
    
    func test_exploreListVC_doesNotPerformSearchIfTextFieldIsEmpty() {
        launchAppForNetworkSuccessCase()
        
        _ = setUpSearchTextFieldAndEnterText("")
        
        XCTAssertFalse(app.buttons["Search"].firstMatch.isEnabled, "Should be disabled.")
    }
    
    func test_exploreListVC_searchTextField_isDisabled_whenNetworkCallFails() {
        launchAppForNetworkFailureCase(with: .unknown)
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        
        XCTAssertTrue(searchTextField.exists, "Should exist.")
        XCTAssertTrue(searchTextField.isHittable, "Should be able to be tapped.")
        XCTAssertFalse(searchTextField.isEnabled, "Should be disabled.")
        XCTAssertNotNil(searchTextField.placeholderValue, "Should have a placeholder.")
    }
    
    func test_exploreListVC_searchTextField_text_inDarkMode_meetsMinimumContrastRatio() throws {
        launchAppForNetworkSuccessCase()
        
        XCUIDevice.shared.appearance = .dark
        
        try app.performAccessibilityAudit(for: [.contrast]) { issue in
            guard let element = issue.element,
            element.elementType == .searchField else { return true }
            return false
        }
    }
    
    // MARK: - Helper methods
    private func launchAppForNetworkSuccessCase() {
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launchArguments.append("-UITestingMockNetworkSuccess")
        app.launch()
    }
    
    private func launchAppForNetworkFailureCase(with error: UITestError) {
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch(with: error)
    }
    
    private func setUpSearchTextFieldAndEnterText(_ text: String) -> XCUIElement {
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        searchTextField.tap()
        searchTextField.typeText(text)
        return searchTextField
    }
}
