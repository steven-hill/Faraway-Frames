//
//  MockAlertPresenter.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 04/08/2026.
//

import UIKit
@testable import Faraway_Frames

final class MockAlertPresenter: AlertPresenting {
    private(set) var presentedAlert: UIAlertController?
    
    func present(_ alert: UIAlertController,
                 from viewController: UIViewController) {
        presentedAlert = alert
    }
}
