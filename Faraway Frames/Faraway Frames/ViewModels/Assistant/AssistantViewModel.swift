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
        case unknown
        case ready
    }
    
    // MARK: - Properties
    private(set) var status: ModelsStatus = .unknown
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
        default: break
        }
    }
}
