//
//  PersistenceStoresError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/05/2026.
//

import Foundation

enum PersistenceStoresError: Error {
    case loadingStoresFailed(error: Error)
}

extension PersistenceStoresError: Equatable {
    static func == (lhs: PersistenceStoresError, rhs: PersistenceStoresError) -> Bool {
        switch (lhs, rhs) {
        case (.loadingStoresFailed(let lhsError), .loadingStoresFailed(let rhsError)):
            return type(of: lhsError) == type(of: rhsError) &&
            lhsError.localizedDescription == rhsError.localizedDescription
        }
    }
}
