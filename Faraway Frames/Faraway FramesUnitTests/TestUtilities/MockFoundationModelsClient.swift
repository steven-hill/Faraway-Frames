//
//  MockFoundationModelsClient.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels
@testable import Faraway_Frames

final class MockFoundationModelsClient: FoundationModelsService {
    
    //MARK: - Stubs
    var stubbedAvailability: SystemLanguageModelStatus = .ready
    let stubbedResponse = "Here are three films you might like..."
    var stubbedError: TextGenerationError? = nil
    
    //MARK: - Spy property
    private(set) var generateResponseCallCount = 0
    
    //MARK: - Async Pause Support
    var shouldPauseForProcessingStateTest = false
    private var continuation: CheckedContinuation<Void, Never>?
    func resumeExecution() {
        continuation?.resume()
        continuation = nil
    }
    
    //MARK: - Methods
    func checkAvailability() -> SystemLanguageModelStatus {
        return stubbedAvailability
    }
    
    func generateResponse(for film: String) async throws -> String {
        if shouldPauseForProcessingStateTest {
            await withCheckedContinuation { self.continuation = $0 }
        }
        generateResponseCallCount += 1
        if let error = stubbedError {
            throw error
        } else {
            return stubbedResponse
        }
    }
}
