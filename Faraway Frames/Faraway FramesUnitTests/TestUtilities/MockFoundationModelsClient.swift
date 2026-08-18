//
//  MockFoundationModelsClient.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels
@testable import Faraway_Frames

struct MockFoundationModelsClient: FoundationModelsService {
    var stubbedAvailability: SystemLanguageModelStatus = .ready
    let stubbedResponse = "Here are three films you might like..."
    
    func checkAvailability() -> SystemLanguageModelStatus {
        return stubbedAvailability
    }
    
    func generateResponse(for film: String) async throws -> String {
        return stubbedResponse
    }
}
