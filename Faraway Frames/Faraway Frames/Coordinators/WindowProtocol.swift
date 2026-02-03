//
//  WindowProtocol.swift
//  Faraway Frames
//
//  Created by Steven Hill on 03/02/2026.
//

import Foundation
import UIKit

protocol WindowProtocol {
    var rootViewController: UIViewController? { get set }
    func makeKeyAndVisible()
}

extension UIWindow: WindowProtocol {}
