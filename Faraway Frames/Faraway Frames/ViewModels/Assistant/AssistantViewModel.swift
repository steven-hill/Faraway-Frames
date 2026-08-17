//
//  AssistantViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels

final class AssistantViewModel {
    
    // MARK: - Foundation Models Status
    enum ModelsStatus {
        case idle
        case ready
        case unsupportedDevice
        case appleIntelligenceDisabled
        case waitingForModel
    }
    
    // MARK: - Properties
    private(set) var status: ModelsStatus = .idle
    private let foundationModelsClient: FoundationModelsService
    
    // MARK: - Initialisation
    init(foundationModelsClient: FoundationModelsService = FoundationModelsClient()) {
        self.foundationModelsClient = foundationModelsClient
    }
    
    // MARK: - Methods
    func checkModelsAvailability() {
        switch foundationModelsClient.checkAvailability() {
        case .available:
            status = .ready
        case .unavailable(.deviceNotEligible):
            status = .unsupportedDevice
        case .unavailable(.appleIntelligenceNotEnabled):
            status = .appleIntelligenceDisabled
        case .unavailable(.modelNotReady):
            status = .waitingForModel
        default: break
        }
    }
}
