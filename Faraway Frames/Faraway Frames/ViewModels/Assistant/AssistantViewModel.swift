//
//  AssistantViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels
import Foundation

final class AssistantViewModel {
    
    // MARK: - Properties
    private let foundationModelsClient: FoundationModelsService
    private(set) var responseText: String = ""
    
    // MARK: - Initialisation
    init(foundationModelsClient: FoundationModelsService = FoundationModelsClient()) {
        self.foundationModelsClient = foundationModelsClient
    }
    
    // MARK: - Methods
    func checkSystemLanguageModelAvailability() -> SystemLanguageModelStatus {
        return foundationModelsClient.checkAvailability()
    }
    
    func requestFilmRecommendationsFromModel() {
        do {
            let output = try await foundationModelsClient.generateResponse()
            responseText = output
        } catch {
            responseText = "Error: \(error.localizedDescription)"
        }
    }
}
