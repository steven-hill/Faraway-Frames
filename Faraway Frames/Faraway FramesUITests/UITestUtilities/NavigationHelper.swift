//
//  NavigateHelper.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 24/03/2026.
//

import XCTest

struct NavigationHelper {
    static func navigateToExploreTab(app: XCUIApplication) {
        let exploreTab = app.buttons.matching(identifier: "Explore")
        exploreTab.element.firstMatch.tap()
    }
}
