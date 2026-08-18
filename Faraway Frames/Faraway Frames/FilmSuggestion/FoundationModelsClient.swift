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
        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .exceededContextWindowSize:
                throw TextGenerationError.contextWindowExceeded
            case .assetsUnavailable:
                throw TextGenerationError.localAssetsMissing
            case .guardrailViolation:
                throw TextGenerationError.contentBlockedByGuardrails
            case .unsupportedLanguageOrLocale:
                throw TextGenerationError.languageNotSupported
            case .rateLimited:
                throw TextGenerationError.rateLimited
            case .concurrentRequests:
                throw TextGenerationError.systemOverloaded
            case .decodingFailure:
                throw TextGenerationError.outputParsingFailed
            case .refusal:
                throw TextGenerationError.requestRefused
            case .unsupportedGuide:
                throw TextGenerationError.unknown
            @unknown default:
                throw TextGenerationError.unknown
            }
        } catch {
            throw TextGenerationError.unknown
        }
    }
}
