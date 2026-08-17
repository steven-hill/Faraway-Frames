//
//  AssistantViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import Testing
@testable import Faraway_Frames

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
        let sut = AssistantViewModel(foundationModelsClient: mockFoundationModelsClient)
        
        sut.checkModelsAvailability()
        
        #expect(sut.status == .ready, "Should have updated to `.ready`.")
    }
}
