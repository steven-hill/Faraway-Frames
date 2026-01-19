//
//  AlertPresenter.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/01/2026.
//

import UIKit

protocol AlertPresenter: AnyObject {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension UIViewController: AlertPresenter {}
