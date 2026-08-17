//
//  FoundationModelsClient.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels

// MARK: - Client Model Status Definition
enum ClientModelStatus {
    case ready
    case unsupportedDevice
    case appleIntelligenceDisabled
    case waitingForModel
    case unknown
}

final class FoundationModelsClient: FoundationModelsService {
    
    func checkAvailability() -> ClientModelStatus {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .ready
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return .unsupportedDevice
            case .appleIntelligenceNotEnabled: return .appleIntelligenceDisabled
            case .modelNotReady: return .waitingForModel
            @unknown default: return .unknown
            }
        }
    }
}
