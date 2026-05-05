//
//  CurrentDevice.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/05/2026.
//

import UIKit

enum CurrentDevice {
    static var isIPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    static var isIPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
}
