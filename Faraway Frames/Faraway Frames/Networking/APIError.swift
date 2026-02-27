//
//  APIError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

enum APIError: Error, Equatable {
    case noInternetConnection
    case networkTimeout
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case unknown
    
    var description: String {
        switch self {
        case .noInternetConnection:
            return "The internet connection appears to be offline"
        case .networkTimeout:
            return "Network request timed out"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(statusCode: let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError:
            return "Failed to decode data"
        case .unknown:
            return "Unknown error"
        }
    }
}
