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
        case .noInternetConnection:
            return "APIError.noInternetConnection"
        case .networkConnectionLost:
            return "APIError.networkConnectionLost"
        case .networkTimeout:
            return "APIError.networkTimeout"
        case .invalidURL:
            return "APIError.invalidURL"
        case .invalidResponse:
            return "APIError.invalidResponse"
        case .serverError(let statusCode):
            return "APIError.serverError(statusCode: \(statusCode))"
        case .decodingError(let context):
            return "APIError.decodingError: \(context)"
        case .unknown:
            return "APIError.unknown"
        }
    }
}

// MARK: - Mapping Logic
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
