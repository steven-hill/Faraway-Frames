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
    nonisolated var errorDescription: String? {
        switch self {
        case .addFailed(let reason):
            return "Failed to add film. \(reason.description)"
        case .deleteFailed(let reason):
            return "Failed to remove film. \(reason.description)"
        }
    }
}

extension FilmDetailError.FailureReason {
    nonisolated var description: String {
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

extension FilmDetailError {
    private static func mapReason(_ error: Error) -> FailureReason {
        if let cocoaError = error as? CocoaError {
            switch cocoaError.code {
            case .fileWriteOutOfSpace:
                return .diskFull
            case .persistentStoreOpen, .persistentStoreTypeMismatch, .managedObjectReferentialIntegrity:
                return .databaseError
            default:
                return .databaseError
            }
        }
        return .unknown(error.localizedDescription)
    }
    
    static func add(_ error: Error) -> Self { .addFailed(mapReason(error)) }
    static func delete(_ error: Error) -> Self { .deleteFailed(mapReason(error)) }
}
