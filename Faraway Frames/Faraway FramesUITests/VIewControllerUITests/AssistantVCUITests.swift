//
//  AssistantVCUITests.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 20/03/2026.
//

import XCTest

final class AssistantVCUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testExample() {
    }
}
