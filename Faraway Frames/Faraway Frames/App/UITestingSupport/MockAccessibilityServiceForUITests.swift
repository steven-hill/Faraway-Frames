//
//  MockAccessibilityServiceForUITests.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/07/2026.
//

import UIKit

final class MockAccessibilityServiceForUITests: AccessibilityService {
    var isVoiceOverRunning = false
    
    func post(notification: UIAccessibility.Notification, argument: Any?) {
    }
}
