//
//  FFButtonTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 24/06/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct FFButtonTests {

    @Test("Button supports changing its title, image and accessibility properties while others remain unchanged.")
    func ffButton_update_modifiesTitleImageAndAccessibilityPropertiesOnly() {
        let testVC = UIViewController()
        let sut = FFButton(
                    title: "Initial Title",
                    systemImageName: "plus",
                    accessibilityIdentifier: "test_id",
                    accessibilityHint: "Initial Hint"
                )
        testVC.view.addSubview(sut)
        testVC.loadViewIfNeeded()
        
        sut.update(title: "New Title", systemImageName: "minus", accessibilityHint: "New Hint")
        
        #expect(sut.configuration?.title == "New Title", "Should have been updated.")
        #expect(sut.configuration?.image == UIImage(systemName: "minus"), "Should have been updated.")
        #expect(sut.accessibilityHint == "New Hint", "Should have been updated.")
        #expect(sut.accessibilityIdentifier == "test_id", "Should be unchanged.")
    }
}
