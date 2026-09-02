//
//  CurrentDevice.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/05/2026.
//

import UIKit

enum CurrentDevice {
    static let isIPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    static let isIPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
}
