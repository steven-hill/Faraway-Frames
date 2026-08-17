//
//  SystemLanguageModelStatus.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import Foundation

/// Wraps `SystemLanguageModel.default.availability` into a custom enum.
enum SystemLanguageModelStatus {
    case ready
    case unsupportedDevice
    case appleIntelligenceDisabled
    case waitingForModel
    case unknown
}
