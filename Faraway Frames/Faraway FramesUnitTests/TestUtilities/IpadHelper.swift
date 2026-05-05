//
//  IpadHelper.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 02/03/2026.
//

import UIKit

struct IpadHelper {
    static let isPad = DispatchQueue.main.sync { CurrentDevice.isIPad }
}
