//
//  DecodingError+Ext.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/07/2026.
//

import Foundation

extension DecodingError {
    /// Helper to extract context for logs in APIError.
    var failureReasonForLogs: String {
        switch self {
        case .typeMismatch(let type, let context):
            return "Type mismatch for type \(type). Path: \(context.codingPath.map(\.stringValue).joined(separator: ".")) — \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Value not found for type \(type). Path: \(context.codingPath.map(\.stringValue).joined(separator: ".")) — \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found. Path: \(context.codingPath.map(\.stringValue).joined(separator: ".")) — \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Data corrupted. Path: \(context.codingPath.map(\.stringValue).joined(separator: ".")) — \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding failure: \(self.localizedDescription)"
        }
    }
}
