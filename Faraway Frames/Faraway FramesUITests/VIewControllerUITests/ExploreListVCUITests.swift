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
        XCUIDevice.shared.appearance = .light
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
    
    func test_exploreListVC_whenNotConnectedToInternetAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .noInternetConnection)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertFalse(header.exists)
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_whenNetworkConnectionIsLostAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .networkConnectionLost)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertFalse(header.exists)
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
    }
    
    func test_exploreListVC_whenNetworkRequestTimesOutAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .networkTimeout)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenURLIsInvalidAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .invalidURL)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenResponseIsInvalidAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .invalidResponse)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenServerReturns500ErrorAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .serverError(statusCode: 500))
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_forDecodingErrorAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .decodingError)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_forUnknownErrorAndNoArchivedDataIsAvailable_showsErrorMessageAndRetryButton() {
        launchAppForNetworkFailureCase(with: .unknown)
        
        let header = app.collectionViews.staticTexts["Network_Error_Reusable_View"]
        
        XCTAssertTrue(app.otherElements["ExploreListVC_ErrorView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["ErrorView_Title_Label"].exists, "Should show primary error text.")
        XCTAssertTrue(app.staticTexts["ErrorView_Secondary_Label"].exists, "Should show error secondary text.")
        XCTAssertTrue(app.buttons["ErrorView_Retry_Button"].isHittable, "Retry button should be tappable.")
        XCTAssertFalse(header.exists)
    }
    
    func test_exploreListVC_whenNetworkCallFails_butFileManagerDataExists_collectionViewHeaderAppears() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockNetworkFailureWithFileManagerData"]
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
        let header = app.otherElements["Network_Error_Header_View"]
        
        XCTAssertTrue(header.waitForExistence(timeout: 1))
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
        XCTAssertTrue(app.otherElements["ExploreListVC_EmptySearchResultsView"].exists, "Should show container view.")
        XCTAssertTrue(app.staticTexts["Empty_Search_Results_Title_Label"].exists, "Should show primary text.")
        XCTAssertTrue(app.staticTexts["Empty_Search_Results_Secondary_Label"].exists, "Should show secondary text.")
    }
    
    func test_exploreListVC_emptySearchResultsView_adaptsLayoutToLandscapeOrientationAndLargeAccessibilityTextSizes() {
        XCUIDevice.shared.orientation = .landscapeLeft
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockNetworkSuccess"]
        app.launchArguments += [
                "-UIPreferredContentSizeCategoryName",
                UIContentSizeCategory.accessibilityExtraExtraExtraLarge.rawValue
        ]
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
        
        _ = setUpSearchTextFieldAndEnterText("Invalid query\n")
        let collectionView = app.collectionViews.element
        let emptySearchResultsContainer = app.otherElements["ExploreListVC_EmptySearchResultsView"]
        
        XCTAssertFalse(collectionView.exists, "Collection view should be hidden.")
        XCTAssertTrue(emptySearchResultsContainer.exists, "Should show container view.")
        XCTAssertFalse(emptySearchResultsContainer.images["Empty_Search_Results_Icon_Image"].isHittable, "Should hide icon.")
        XCTAssertTrue(app.staticTexts["Empty_Search_Results_Title_Label"].isHittable, "Should show primary text.")
        XCTAssertTrue(app.staticTexts["Empty_Search_Results_Secondary_Label"].isHittable, "Should show secondary text.")
        
        XCUIDevice.shared.orientation = .portrait
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
        XCUIDevice.shared.appearance = .dark
        launchAppForNetworkSuccessCase()
        
        try app.performAccessibilityAudit(for: [.contrast]) { issue in
            guard let element = issue.element,
                  element.elementType == .searchField else { return true }
            return false
        }
    }
    
    // MARK: - Helper methods
    private func launchAppForNetworkSuccessCase() {
        app = XCUIApplication()
        app.launchArguments = ["-UITesting",
                               "-UITestingMockNetworkSuccess"]
        app.launch()
        NavigationHelper.navigateToExploreTab(app: app)
    }
    
    private func launchAppForNetworkFailureCase(with error: UITestNetworkError) {
        app = XCUIApplication()
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
