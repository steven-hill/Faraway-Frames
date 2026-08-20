//
//  MockFoundationModelsClientForUITests.swift
//  Faraway Frames
//
//  Created by Steven Hill on 20/08/2026.
//

import Foundation

final class MockFoundationModelsClientForUITests: FoundationModelsService {
    func checkAvailability() -> SystemLanguageModelStatus {
        .ready
    }
    
    func generateResponse(for film: String) async throws -> String {
        "Here are three films you might like..."
    }
}
