//
//  LaunchArguments.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import Foundation

enum LaunchArguments {
    static let uiTesting = "-UITesting"
    static let uiTestingMockNetworkSuccess = "-UITestingMockNetworkSuccess"
    static let uiTestingMockNetworkFailureWithFileManagerData = "-UITestingMockNetworkFailureWithFileManagerData"
    static let uiTestingMockNetworkFailure = "-UITestingMockNetworkFailure"
    static let uiTestingMockPersistenceData = "-UITestingMockPersistenceData"
    static let uiTestingPersistenceSaveError = "-UITestingPersistenceSaveError"
    static let uiTestingHomeVCPersistenceLoadError = "-UITestingHomeVCPersistenceLoadError"
    static let uiTestingExploreDetailVCPersistenceLoadError = "-UITestingExploreDetailVCPersistenceLoadError"
}
