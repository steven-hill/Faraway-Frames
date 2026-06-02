//
//  HomeUpNextError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 02/06/2026.
//

import Foundation
import CoreData

enum HomeUpNextError: Error, Identifiable, Equatable {
    case databaseAccessError
    case diskFull
    case unknown(String)
    
    var id: String { localizedDescription }
    
    var localizedDescription: String {
        switch self {
        case .databaseAccessError:
            return "Unable to access database. Try restarting the app."
        case .diskFull:
            return "Device storage full. Try freeing up some space."
        case .unknown(let message):
            return message
        }
    }

    static func == (lhs: HomeUpNextError, rhs: HomeUpNextError) -> Bool {
        switch (lhs, rhs) {
        case (.databaseAccessError, .databaseAccessError):
            return true
        case (.diskFull, .diskFull):
            return true
        case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

extension HomeUpNextError {
    init(_ error: Error) {
        if let cocoaError = error as? CocoaError {
            switch cocoaError.code {
            case .fileWriteOutOfSpace:
                self = .diskFull
            case .persistentStoreOpen,
                 .managedObjectReferentialIntegrity,
                 .persistentStoreTypeMismatch:
                self = .databaseAccessError
            default:
                self = .databaseAccessError
            }
        } else {
            self = .unknown(error.localizedDescription)
        }
    }
}
