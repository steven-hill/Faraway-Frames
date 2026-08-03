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
    private var continuation: CheckedContinuation<Void, Never>?
    private var notificationPosted = false
    
    func post(notification: UIAccessibility.Notification, argument: Any?) {
        notificationPosted = true
        postCallCount += 1
        postedNotification = notification
        postedArgument = argument
        continuation?.resume()
        continuation = nil
    }
    
    func waitForNotification() async {
        if notificationPosted { return }
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}
