//
//  MockAccessibilityService.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 01/07/2026.
//

import UIKit
@testable import Faraway_Frames

final class MockAccessibilityService: AccessibilityService {
    var isVoiceOverRunningStub = false
    private(set) var postedNotification: UIAccessibility.Notification?
    private(set) var postedArgument: Any?
    var isVoiceOverRunning: Bool { isVoiceOverRunningStub }
    private(set) var postCallCount = 0
    
    func post(notification: UIAccessibility.Notification, argument: Any?) {
        postCallCount += 1
        postedNotification = notification
        postedArgument = argument
    }
}
