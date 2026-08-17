//
//  MockFoundationModelsClient.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels
@testable import Faraway_Frames

final class MockFoundationModelsClient: FoundationModelsService {
    var stubbedAvailability: SystemLanguageModelStatus = .ready
    
    func checkAvailability() -> SystemLanguageModelStatus {
        return stubbedAvailability
    }
}
