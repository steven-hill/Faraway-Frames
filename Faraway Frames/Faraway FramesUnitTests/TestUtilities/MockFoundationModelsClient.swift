//
//  MockFoundationModelsClient.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels
@testable import Faraway_Frames
import Foundation

final class MockFoundationModelsClient: FoundationModelsService {
    
    //MARK: - Stubs
    var stubbedAvailability: SystemLanguageModelStatus = .ready
    var stubbedResponse = "Here are three films you might like..."
    var shouldThrowError = false
    
    //MARK: - Spy property
    private(set) var generateResponseCallCount = 0
    
    func checkAvailability() -> SystemLanguageModelStatus {
        return stubbedAvailability
    }
    
    func generateResponse(for film: String) async throws -> String {
        generateResponseCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        } else {
            return stubbedResponse
        }
    }
}
