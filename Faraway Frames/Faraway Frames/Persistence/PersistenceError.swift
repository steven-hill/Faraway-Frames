//
//  PersistenceError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/05/2026.
//

import Foundation

enum PersistenceError: Error {
    case loadingStoresFailed(error: Error)
    case savingFailed(error: Error)
}

extension PersistenceError: Equatable {
    static func == (lhs: PersistenceError, rhs: PersistenceError) -> Bool {
        switch (lhs, rhs) {
        case (.loadingStoresFailed(let lhsType), .loadingStoresFailed(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        case (.savingFailed(let lhsType), .savingFailed(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        default:
            return false
        }
    }
}
