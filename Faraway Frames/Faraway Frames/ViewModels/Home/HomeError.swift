//
//  HomeError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData

enum HomeError: Error, Equatable {
    case fetchFailed(PersistenceFailureReason)
    case addFailed(PersistenceFailureReason)
    case deleteFailed(PersistenceFailureReason)
}

// MARK: - User-facing Descriptions
extension HomeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Error loading films."
        case .addFailed:
            return "Error adding film."
        case .deleteFailed:
            return "Error removing film."
        }
    }
}

extension HomeError {
    @MainActor
    var secondaryText: String {
        switch self {
        case .fetchFailed(let reason),
                .addFailed(let reason),
                .deleteFailed(let reason):
            return reason.message
        }
    }
}
