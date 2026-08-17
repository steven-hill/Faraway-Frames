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

    @Test("On init the status should be unknown")
    func assistantViewModel_onInit_statusIsUnknown() {
        let sut = AssistantViewModel()
        
        #expect(sut.status == .unknown, "Should be `.unknown` initially.")
    }
    
    @Test("When `SystemLanguageModel` is available, status updates correctly")
    func assistantViewModel_checkAvailability_whenTheModelIsAvailable_statusChangesToReady() {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        mockFoundationModelsClient.stubbedAvailability = .available
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        sut.checkModelsAvailability()
        
        #expect(sut.status == .ready, "Should have updated to `.ready`.")
    }
    
    @Test("When device doesn't support Apple Intelligence, status updates correctly")
    func assistantViewModel_checkAvailability_whenDeviceDoesNotSupportAppleIntelligence_statusChangesToReady() {
        let mockFoundationModelsClient = MockFoundationModelsClient()
        mockFoundationModelsClient.stubbedAvailability = .unavailable(.deviceNotEligible)
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        sut.checkModelsAvailability()
        
        #expect(sut.status == .unsupportedDevice, "Should have updated to `.unsupportedDevice`.")
    }
}
