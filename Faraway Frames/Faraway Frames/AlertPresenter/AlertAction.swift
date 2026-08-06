//
//  AlertAction.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/08/2026.
//

import UIKit

/// A data model representing an alert button.
struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((AlertAction) -> Void)?
    
    func toUIKitAction() -> UIAlertAction {
        return UIAlertAction(title: title, style: style) { _ in
            self.handler?(self)
        }
    }
}
