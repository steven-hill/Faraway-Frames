//
//  FilmDetailError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/06/2026.
//

import Foundation
import CoreData

enum FilmDetailError: Error, Equatable {
    case addFailed(PersistenceFailureReason)
    case deleteFailed(PersistenceFailureReason)
}

// MARK: - User-facing Description
extension FilmDetailError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .addFailed:
            return "Error adding film"
        case .deleteFailed:
            return "Error removing film"
        }
    }
}

// MARK: - User-facing Secondary Text
extension FilmDetailError {
    @MainActor
    var secondaryText: String {
        switch self {
        case .addFailed(let reason),
                .deleteFailed(let reason):
            return reason.message
        }
    }
}
