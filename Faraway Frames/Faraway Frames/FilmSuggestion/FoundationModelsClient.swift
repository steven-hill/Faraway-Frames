//
//  FoundationModelsClient.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels

struct FoundationModelsClient: FoundationModelsService {
    
    /// Maps framework's enum into custom enum.
    func checkAvailability() -> SystemLanguageModelStatus {
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
