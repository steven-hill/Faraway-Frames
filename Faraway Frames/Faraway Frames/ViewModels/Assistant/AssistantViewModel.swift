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
        case unknown
    }
    
    // MARK: - Properties
    private(set) var status: ModelsStatus = .idle
    private let foundationModelsClient: FoundationModelsService
    
    // MARK: - Initialisation
    init(foundationModelsClient: FoundationModelsService = FoundationModelsClient()) {
        self.foundationModelsClient = foundationModelsClient
    }
    
    // MARK: - Method
    func checkSystemLanguageModelAvailability() {
        switch foundationModelsClient.checkAvailability() {
        case .ready:
            status = .ready
        case .unsupportedDevice:
            status = .unsupportedDevice
        case .appleIntelligenceDisabled:
            status = .appleIntelligenceDisabled
        case .waitingForModel:
            status = .waitingForModel
        case .unknown:
            status = .unknown
        }
    }
}
