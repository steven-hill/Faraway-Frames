//
//  FoundationModelsService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels

protocol FoundationModelsService {
    func checkAvailability() -> SystemLanguageModelStatus
    func generateResponse(for film: String) async throws -> String
}
