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
    var isUITestingMockNetworkSuccess: Bool {
        arguments.contains(LaunchArguments.uiTestingMockNetworkSuccess)
    }
    var isUITestingMockNetworkFailureWithFileManagerData: Bool {
        arguments.contains(LaunchArguments.uiTestingMockNetworkFailureWithFileManagerData)
    }
    var isUITestingMockNetworkFailure: Bool {
        arguments.contains(LaunchArguments.uiTestingMockNetworkFailure)
    }
}
