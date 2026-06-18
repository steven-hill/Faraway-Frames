//
//  ThrowingSaver.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/06/2026.
//

import Foundation
@testable import Faraway_Frames

/// Used in tests for failure when saving Core Data context.
final class ThrowingSaver: ContextSaving, Sendable {
    let errorToThrow: Error
    
    init(errorToThrow: Error) {
        self.errorToThrow = errorToThrow
    }
    
    nonisolated func save() throws {
        throw errorToThrow
    }
}
