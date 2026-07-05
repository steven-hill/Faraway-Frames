//
//  FilmDetailError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/06/2026.
//

import Foundation
import CoreData

enum FilmDetailError: Error, Equatable {
    
    enum FailureReason: Equatable {
        case diskFull
        case databaseError
        case unknown(String)
        
        var message: String {
            switch self {
            case .diskFull:
                return "Your device storage is full. Free up space and try again."
            case .databaseError:
                return "There was a problem with the database. Please try again."
            case .unknown(let message):
                return message
            }
        }
    }
    
    case addFailed(FailureReason)
    case deleteFailed(FailureReason)
}

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

extension FilmDetailError {
    var secondaryText: String {
        switch self {
        case .addFailed(let reason),
                .deleteFailed(let reason):
            return reason.message
        }
    }
}

extension FilmDetailError {
    private static func mapReason(_ error: Error) -> FailureReason {
        guard let cocoaError = error as? CocoaError else {
            return .unknown(error.localizedDescription)
        }
        
        switch cocoaError.code {
        case .fileWriteOutOfSpace:
            return .diskFull
        case .persistentStoreOpen,
                .persistentStoreTypeMismatch,
                .managedObjectReferentialIntegrity:
            return .databaseError
        default:
            return .databaseError
        }
    }
    
    static func add(_ error: Error) -> Self { .addFailed(mapReason(error)) }
    static func delete(_ error: Error) -> Self { .deleteFailed(mapReason(error)) }
}
