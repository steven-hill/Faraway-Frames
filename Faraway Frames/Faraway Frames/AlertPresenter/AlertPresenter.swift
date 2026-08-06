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
    
    func presentAlert(title: String?, message: String?, actions: [AlertAction], from viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions.forEach { wrapperAction in
            alert.addAction(wrapperAction.toUIKitAction())
        }
        
        viewController.present(alert, animated: true)
    }
}
