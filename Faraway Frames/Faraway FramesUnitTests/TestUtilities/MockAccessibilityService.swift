//
//  MockAccessibilityService.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 01/07/2026.
//

import UIKit
@testable import Faraway_Frames

final class MockAccessibilityService: AccessibilityService {
    var isVoiceOverRunning = false
    
    func post(notification: UIAccessibility.Notification, argument: Any?) {
    }
}
