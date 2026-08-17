//
//  AssistantViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/08/2026.
//

import Foundation

final class AssistantViewModel {
    
    // MARK: - Foundation Models Status
    enum ModelsStatus {
        case unknown
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
        
    }
}
