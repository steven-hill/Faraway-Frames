//
//  PersistenceFailureReason.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/07/2026.
//

import Foundation
import CoreData

enum PersistenceFailureReason: Equatable {
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

extension PersistenceFailureReason {
    init(from error: Error) {
        guard let cocoaError = error as? CocoaError else {
            self = .unknown(error.localizedDescription)
            return
        }
        
        switch cocoaError.code {
        case .fileWriteOutOfSpace:
            self = .diskFull
        case .persistentStoreOpen,
                .persistentStoreTypeMismatch,
                .managedObjectReferentialIntegrity:
            self = .databaseError
        default:
            self = .databaseError
        }
    }
}
