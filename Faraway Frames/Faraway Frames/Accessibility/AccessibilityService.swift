//
//  AccessibilityService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/07/2026.
//

import UIKit

protocol AccessibilityService {
    var isVoiceOverRunning: Bool { get }
    func post(notification: UIAccessibility.Notification, argument: Any?)
}
