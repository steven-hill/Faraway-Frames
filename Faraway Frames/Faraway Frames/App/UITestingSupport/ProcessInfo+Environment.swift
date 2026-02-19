//
//  ProcessInfoExtension.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import Foundation

extension ProcessInfo {
    var isUITesting: Bool {
        arguments.contains(LaunchArguments.uiTesting)
    }
}
