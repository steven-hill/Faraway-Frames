//
//  HomeError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData

enum HomeError: Error, Equatable {
    
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
    
    case fetchFailed(FailureReason)
    case addFailed(FailureReason)
    case deleteFailed(FailureReason)
}

extension HomeError: LocalizedError {
    nonisolated var errorDescription: String? {
        switch self {
        case .fetchFailed(let reason):
            return "Failed to load films. \(reason)"
        case .addFailed(let reason):
            return "Failed to add film. \(reason)"
        case .deleteFailed(let reason):
            return "Failed to delete film. \(reason)"
        }
    }
}

extension HomeError {
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
    
    static func fetch(_ error: Error) -> Self { .fetchFailed(mapReason(error)) }
    static func add(_ error: Error) -> Self { .addFailed(mapReason(error)) }
    static func delete(_ error: Error) -> Self { .deleteFailed(mapReason(error)) }
}
