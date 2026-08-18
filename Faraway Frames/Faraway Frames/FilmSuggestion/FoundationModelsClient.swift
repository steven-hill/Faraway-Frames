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
    
    func generateResponse(for film: String) async throws -> String {
        let session = LanguageModelSession(
            instructions: """
            You are a film critic, specialising in the films of Studio Ghibli.
            """
        )
        let prompt = "I like the Studio Ghibli film called \(film). Based on that film, what Studio Ghibli films do you recommend I watch next? Recommend no more than three."
        let response = try await session.respond(to: prompt)
        return response.content
    }
}
