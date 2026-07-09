//
//  UIView+Ext.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 09/07/2026.
//

import UIKit

/// Finds a UIView from its accessibility identifier.
/// Used in some ExploreDetailVC unit tests.
extension UIView {
    func findView(withIdentifier identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier {
            return self
        }
        for subview in subviews {
            if let foundView = subview.findView(withIdentifier: identifier) {
                return foundView
            }
        }
        return nil
    }
}
