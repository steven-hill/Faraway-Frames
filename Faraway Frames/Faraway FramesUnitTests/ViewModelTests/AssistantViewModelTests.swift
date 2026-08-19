//
//  AssistantViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import Testing
@testable import Faraway_Frames
import FoundationModels
import Foundation

@MainActor
struct AssistantViewModelTests {
    
    @Test("View model state is `.idle` on init")
    func assistantViewModel_initialState_isIdle() {
        let sut = AssistantViewModel()
        #expect(sut.currentState == .idle, "Should be `.idle` on init.")
    }
    
    @Test("View model can get the system language model availability status from the service",
          arguments: [
            SystemLanguageModelStatus.ready,
            SystemLanguageModelStatus.unsupportedDevice,
            SystemLanguageModelStatus.appleIntelligenceDisabled,
            SystemLanguageModelStatus.waitingForModel,
            SystemLanguageModelStatus.unknown
          ])
    func assistantViewModel_checkSystemLanguageModelAvailability_returnsModelAvailabilityFromService(testCase: SystemLanguageModelStatus) {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        mockFoundationModelsClient.stubbedAvailability = testCase
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        let status = sut.checkSystemLanguageModelAvailability()
        
        #expect(status == testCase, "`status` should match the expected value.")
    }
    
    @Test("View model updates response text when the model successfully generates a response")
    func assistantViewModel_requestFilmRecommendationsFromModel_whenModelGeneratesResponse_updatesResponseText() async throws {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        try #require(sut.responseText.isEmpty, "Should be empty initially.")
        
        await sut.requestFilmRecommendationsFromModel(for: Film.sample[0].title)
        
        #expect(sut.responseText == mockFoundationModelsClient.stubbedResponse, "Should update with model's response.")
        #expect(mockFoundationModelsClient.generateResponseCallCount == 1, "Should have called method once.")
    }
    
    @Test("View model handles model error correctly",
          arguments: [
            TextGenerationError.contextWindowExceeded,
            TextGenerationError.contentBlockedByGuardrails,
            TextGenerationError.languageNotSupported,
            TextGenerationError.localAssetsMissing,
            TextGenerationError.outputParsingFailed,
            TextGenerationError.rateLimited,
            TextGenerationError.requestRefused,
            TextGenerationError.systemOverloaded,
            TextGenerationError.unknown
          ])
    func assistantViewModel_requestFilmRecommendationsFromModel_whenRequestToModelResultsInError_handlesError(error: TextGenerationError) async {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        mockFoundationModelsClient.stubbedError = error
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        await sut.requestFilmRecommendationsFromModel(for: Film.sample[0].title)
        
        #expect(sut.errorMessage == error.localizedDescription, "Should match.")
        #expect(sut.responseText.isEmpty, "Should still be empty.")
    }
}
