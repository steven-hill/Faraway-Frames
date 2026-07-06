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
    case decodingError
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
