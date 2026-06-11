//
//  HomeError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData

enum HomeError: Error, Identifiable, Equatable {
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
}

extension HomeError {
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
