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

    @Test("On init the status is correct")
    func assistantViewModel_onInit_statusIsCorrect() {
        let sut = AssistantViewModel()
        
        #expect(sut.status == .idle, "Should be `.idle` initially.")
    }
    
    @Test("View model correctly maps system language model availability states",
          arguments: [
            ModelAvailabilityTestCase(
                availability: .ready,
                expectedStatus: .ready
            ),
            ModelAvailabilityTestCase(
                availability: .unsupportedDevice,
                expectedStatus: .unsupportedDevice
            ),
            ModelAvailabilityTestCase(
                availability: .appleIntelligenceDisabled,
                expectedStatus: .appleIntelligenceDisabled
            ),
            ModelAvailabilityTestCase(
                availability: .waitingForModel,
                expectedStatus: .waitingForModel
            ),
            ModelAvailabilityTestCase(
                availability: .unknown,
                expectedStatus: .unknown
            )
          ])
    func assistantViewModel_checkAvailability_mapsModelAvailabilityCorrectly(testCase: ModelAvailabilityTestCase) {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        mockFoundationModelsClient.stubbedAvailability = testCase.availability
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        sut.checkModelsAvailability()
        
        #expect(sut.status == testCase.expectedStatus, "`status` should have been updated correctly.")
    }
    
    // MARK: - System Language Model Availability
    struct ModelAvailabilityTestCase {
        let availability: SystemLanguageModelStatus
        let expectedStatus: AssistantViewModel.ModelsStatus
    }
}
