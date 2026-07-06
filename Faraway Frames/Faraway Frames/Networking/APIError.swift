//
//  APIError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

enum APIError: Error, Equatable {
    case noInternetConnection
    case networkConnectionLost
    case networkTimeout
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(String)
    case unknown
}

// MARK: - User Facing Descriptions
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "The internet connection appears to be offline."
        case .networkConnectionLost:
            return "The network connection was lost."
        case .networkTimeout:
            return "The network request timed out."
        case .invalidURL, .invalidResponse, .decodingError:
            return "Something went wrong. Please try again."
        case .serverError(let statusCode):
            return "The server responded with an error (Status: \(statusCode))."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

// MARK: - Debugging Descriptions
extension APIError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .serverError(let statusCode):
            return "APIError.serverError(statusCode: \(statusCode))"
        case .decodingError(let context):
            return "APIError.decodingError: \(context)"
        default:
            return String(reflecting: self)
        }
    }
}

extension APIError {
    /// Converts generic network or system errors into a strongly-typed APIError.
    init(from error: Error) {
        if let apiError = error as? APIError {
            self = apiError
            return
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                self = .noInternetConnection
            case .networkConnectionLost:
                self = .networkConnectionLost
            case .timedOut:
                self = .networkTimeout
            default:
                self = .unknown
            }
            return
        }
        
        if let decodingError = error as? DecodingError {
            self = .decodingError(decodingError.failureReasonForLogs)
            return
        }
        
        self = .unknown
    }
}

private extension DecodingError {
    /// Helper to extract context for logs.
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
