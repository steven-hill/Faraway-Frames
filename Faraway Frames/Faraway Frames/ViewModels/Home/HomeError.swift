//
//  HomeError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData

nonisolated enum HomeError: Error, Equatable, Sendable {
    case fetchFailed(PersistenceFailureReason)
    case addFailed(PersistenceFailureReason)
    case removeFailed(PersistenceFailureReason)
}

// MARK: - User-facing Description
extension HomeError: LocalizedError {
    nonisolated var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Error loading films."
        case .addFailed:
            return "Error adding film."
        case .removeFailed:
            return "Error removing film."
        }
    }
}

// MARK: - User-facing Secondary Text
extension HomeError {
    nonisolated var secondaryText: String {
        switch self {
        case .fetchFailed(let reason),
                .addFailed(let reason),
                .removeFailed(let reason):
            return reason.message
        }
    }
}
