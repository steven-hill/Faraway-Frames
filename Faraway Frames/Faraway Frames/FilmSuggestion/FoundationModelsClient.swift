//
//  FoundationModelsClient.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import FoundationModels

final class FoundationModelsClient: FoundationModelsService {
    func checkAvailability() -> SystemLanguageModel.Availability {
        return SystemLanguageModel.default.availability
    }
}
