//
//  MockFoundationModelsClient.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels
@testable import Faraway_Frames
import Foundation

struct MockFoundationModelsClient: FoundationModelsService {
    var stubbedAvailability: SystemLanguageModelStatus = .ready
    var stubbedResponse = "Here are three films you might like..."
    var shouldThrowError = false
    
    func checkAvailability() -> SystemLanguageModelStatus {
        return stubbedAvailability
    }
    
    func generateResponse(for film: String) async throws -> String {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        } else {
            return stubbedResponse
        }
    }
}
