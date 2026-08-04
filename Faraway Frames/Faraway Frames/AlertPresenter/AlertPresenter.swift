//
//  AlertPresenter.swift
//  Faraway Frames
//
//  Created by Steven Hill on 04/08/2026.
//

import UIKit

final class AlertPresenter: AlertPresenting {
    func present(_ alert: UIAlertController,
                 from viewController: UIViewController) {
        viewController.present(alert, animated: true)
    }
}
