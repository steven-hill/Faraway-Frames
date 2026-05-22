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
    
    func test_exploreListVC_inContentState_displaysCollectionView() {
        launchAppForNetworkSuccessCase()
        
        let collectionView = app.collectionViews.element
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(collectionView.exists, "Should exist.")
        XCTAssertGreaterThan(collectionView.cells.count, 0, "Should be more than zero cells.")
        XCTAssertTrue(collectionView.cells.firstMatch.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(collectionView.cells.images["Film_Cell_Poster"].exists, "Cells should have an image.")
        XCTAssertTrue(collectionView.cells.staticTexts["Film_Cell_Title"].exists, "Cells should have a text label.")
        XCTAssertFalse(header.exists)
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
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["The internet connection appears to be offline"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenNetworkConnectionIsLost_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .networkConnectionLost)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Network connection lost"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenNetworkRequestTimesOut_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .networkTimeout)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Network request timed out"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenURLIsInvalid_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .invalidURL)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Invalid URL"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenResponseIsInvalid_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .invalidResponse)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Invalid response"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenServerReturns500Error_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .serverError(statusCode: 500))
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Server error with status code: 500"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_forDecodingError_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .decodingError)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Failed to decode data"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_forUnknownError_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .unknown)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.staticTexts["Error loading films"].exists, "Should show error text.")
        XCTAssertTrue(app.staticTexts["Unknown error"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["Retry"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_searchTextField_initialState() {
        launchAppForNetworkSuccessCase()
        
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        
        XCTAssertTrue(searchTextField.exists, "Should exist.")
        XCTAssertTrue(searchTextField.isHittable, "Should be able to be tapped.")
        XCTAssertTrue(searchTextField.isEnabled, "Should be enabled.")
        XCTAssertNotNil(searchTextField.placeholderValue, "Should have a placeholder.")
    }
    
    func test_exploreListVC_searchTextField_whenSearching_displaysACancelButton() {
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
    
    func test_exploreListVC_searchTextField_canClearTextViaDeleteKey() {
        launchAppForNetworkSuccessCase()
        
        let searchTextField = setUpSearchTextFieldAndEnterText("C")
        app.keys["delete"].firstMatch.tap()
        
        XCTAssertEqual(searchTextField.value as? String, searchTextField.placeholderValue, "Should revert to placeholder text.")
    }
    
    func test_exploreListVC_searchTextField_withValidSearchQuery_showsSearchResults() {
        launchAppForNetworkSuccessCase()
        
        _ = setUpSearchTextFieldAndEnterText("Castle in the Sky")
        let collectionView = app.collectionViews.element
        
        XCTAssertEqual(collectionView.cells.count, 1, "Should have one film in search results.")
    }
    
    func test_exploreListVC_searchTextField_withInValidSearchQuery_showsNoSearchResults() {
        launchAppForNetworkSuccessCase()
        
        _ = setUpSearchTextFieldAndEnterText("Invalid query")
        let collectionView = app.collectionViews.element
        
        XCTAssertFalse(collectionView.exists, "Collection view should be hidden.")
    }
    
    func test_exploreListVC_searchTextField_searchQueryisEmpty_isDisabled() {
        launchAppForNetworkSuccessCase()
        
        _ = setUpSearchTextFieldAndEnterText("")
        
        XCTAssertFalse(app.buttons["Search"].firstMatch.isEnabled, "Should be disabled.")
    }
    
    func test_exploreListVC_searchTextField_whenNetworkCallFails_isDisabled() {
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
    
    func test_exploreListVC_whenUsingFileManagerData_collectionViewHeaderAppears() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-UITestingMockNetworkFailureWithFileManagerData"]
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
        let header = app.otherElements["Network_Error_Reusable_View"]
        
        XCTAssertTrue(header.waitForExistence(timeout: 1))
    }
    
    // MARK: - Helper methods
    private func launchAppForNetworkSuccessCase() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-UITestingMockNetworkSuccess"]
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    private func launchAppForNetworkFailureCase(with error: UITestError) {
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch(with: error)
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    private func setUpSearchTextFieldAndEnterText(_ text: String) -> XCUIElement {
        NavigationHelper.navigateToExploreTab(app: app)
        let searchTextField = app.searchFields["ExploreListVC_SearchBar_SearchField"]
        searchTextField.tap()
        searchTextField.typeText(text)
        return searchTextField
    }
}
