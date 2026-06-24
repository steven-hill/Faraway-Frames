//
//  FFButtonTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 24/06/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

struct FFButtonTests {

    @Test("Button supports changing its title, image and accessibility properties.")
    func ffButton_update_modifiesTitleImageAndAccessibilityProperties() {
        let sut = FFButton(
            title: "Initial Title",
            systemImageName: "plus",
            accessibilityIdentifier: "test_id",
            accessibilityHint: "Initial Hint"
        )
        
        sut.update(
            title: "New Title",
            systemImageName: "minus",
            accessibilityIdentifier: "new_id",
            accessibilityHint: "New Hint"
        )
        
        #expect(sut.configuration?.title == "New Title", "Should match.")
        #expect(sut.configuration?.image == UIImage(systemName: "minus"), "Should match.")
        #expect(sut.accessibilityIdentifier == "new_id", "Should match.")
        #expect(sut.accessibilityHint == "New Hint", "Should match.")
    }
}
