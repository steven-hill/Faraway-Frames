//
//  UnknownError.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 18/06/2026.
//

import Foundation

/// Used in error scenarios for Core Data operations failure.
struct UnknownError: Error, LocalizedError, Sendable {
    var errorDescription: String? { "Unknown error." }
}
