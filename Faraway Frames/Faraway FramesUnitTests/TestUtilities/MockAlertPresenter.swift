//
//  MockAlertPresenter.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 04/08/2026.
//

import UIKit
@testable import Faraway_Frames

final class MockAlertPresenter: AlertPresenting {
    private(set) var capturedTitle: String?
    private(set) var capturedMessage: String?
    private(set) var capturedActions: [AlertAction] = []
    private(set) var presentedAlert: UIAlertController?
    
    func presentAlert(title: String?, message: String?, actions: [AlertAction], from viewController: UIViewController) {
        capturedTitle = title
        capturedMessage = message
        capturedActions = actions
    }
    
    func present(_ alert: UIAlertController,
                 from viewController: UIViewController) {
        presentedAlert = alert
    }
}
