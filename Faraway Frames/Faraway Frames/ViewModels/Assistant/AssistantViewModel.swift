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
    private(set) var errorMessage: String = ""
    
    // MARK: - Initialisation
    init(foundationModelsClient: FoundationModelsService = FoundationModelsClient()) {
        self.foundationModelsClient = foundationModelsClient
    }
    
    // MARK: - Methods
    func checkSystemLanguageModelAvailability() -> SystemLanguageModelStatus {
        return foundationModelsClient.checkAvailability()
    }
    
    func requestFilmRecommendationsFromModel(for film: String) async {
        do {
            let output = try await foundationModelsClient.generateResponse(for: film)
            responseText = output
        } catch {
            let domainError = error as? TextGenerationError ?? .unknown
            self.errorMessage = domainError.localizedDescription
        }
    }
}
