//
//  AssistantViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels

final class AssistantViewModel {
    
    // MARK: - Property
    private let foundationModelsClient: FoundationModelsService
    
    // MARK: - Initialisation
    init(foundationModelsClient: FoundationModelsService = FoundationModelsClient()) {
        self.foundationModelsClient = foundationModelsClient
    }
    
    // MARK: - Method
    func checkSystemLanguageModelAvailability() -> SystemLanguageModelStatus {
        return foundationModelsClient.checkAvailability()
    }
}
