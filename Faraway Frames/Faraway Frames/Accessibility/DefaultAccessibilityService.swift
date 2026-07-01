//
//  DefaultAccessibilityService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/07/2026.
//

import UIKit

final class DefaultAccessibilityService: AccessibilityService {
    var isVoiceOverRunning: Bool { UIAccessibility.isVoiceOverRunning }
    func post(notification: UIAccessibility.Notification, argument: Any?) {
        UIAccessibility.post(notification: notification, argument: argument)
    }
}
