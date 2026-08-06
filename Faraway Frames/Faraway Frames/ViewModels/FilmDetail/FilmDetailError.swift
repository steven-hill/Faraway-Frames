//
//  FilmDetailError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/06/2026.
//

import Foundation
import CoreData

nonisolated enum FilmDetailError: Error, Equatable, Sendable {
    case fetchFailed(PersistenceFailureReason)
    case addFailed(PersistenceFailureReason)
    case removeFailed(PersistenceFailureReason)
}

// MARK: - User-facing Description
extension FilmDetailError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Error syncing film"
        case .addFailed:
            return "Error adding film"
        case .removeFailed:
            return "Error removing film"
        }
    }
}

// MARK: - User-facing Secondary Text
extension FilmDetailError {
    var secondaryText: String {
        switch self {
        case .fetchFailed(let reason),
                .addFailed(let reason),
                .removeFailed(let reason):
            return reason.message
        }
    }
}
