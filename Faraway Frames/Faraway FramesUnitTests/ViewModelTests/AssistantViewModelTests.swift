//
//  AssistantViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import Testing
@testable import Faraway_Frames
import FoundationModels

@MainActor
struct AssistantViewModelTests {
    
    @Test("View model can get the system language model availability status from the service",
          arguments: [
            SystemLanguageModelStatus.ready,
            SystemLanguageModelStatus.unsupportedDevice,
            SystemLanguageModelStatus.appleIntelligenceDisabled,
            SystemLanguageModelStatus.waitingForModel,
            SystemLanguageModelStatus.unknown
          ])
    func assistantViewModel_checkSystemLanguageModelAvailability_returnsModelAvailabilityFromService(testCase: SystemLanguageModelStatus) {
        var mockFoundationModelsClient = MockFoundationModelsClient()
        mockFoundationModelsClient.stubbedAvailability = testCase
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        let status = sut.checkSystemLanguageModelAvailability()
        
        #expect(status == testCase, "`status` should match the expected value.")
    }
    
    @Test("View model updates response text when the model successfully generates a response")
    func assistantViewModel_whenModelGeneratesResponse_updatesResponseText() async {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        #expect(sut.responseText.isEmpty, "Should be empty initially.")
        
        await sut.requestFilmRecommendationsFromModel()
        
        #expect(sut.responseText == mockFoundationModelsClient.stubbedResponse, "Should update with model's response.")
    }
}
