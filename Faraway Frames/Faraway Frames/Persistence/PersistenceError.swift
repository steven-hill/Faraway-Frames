//
//  PersistenceError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/05/2026.
//

import Foundation

enum PersistenceError: Error {
    case loadingStoresFailed(error: Error)
}

extension PersistenceError: Equatable {
    static func == (lhs: PersistenceError, rhs: PersistenceError) -> Bool {
        switch (lhs, rhs) {
        case (.loadingStoresFailed(let lhsError), .loadingStoresFailed(let rhsError)):
            return type(of: lhsError) == type(of: rhsError) &&
            lhsError.localizedDescription == rhsError.localizedDescription
        }
    }
}
