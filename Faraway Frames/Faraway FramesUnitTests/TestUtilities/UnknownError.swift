//
//  UnknownError.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 18/06/2026.
//

import Foundation

/// Used in error scenarios for Core Data save failures.
struct UnknownError: Error, LocalizedError {
    var errorDescription: String? { "Unknown error." }
}
