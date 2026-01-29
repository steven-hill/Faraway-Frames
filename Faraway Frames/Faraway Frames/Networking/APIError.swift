//
//  APIError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case unknown
    
    var description: String {
        switch self {
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
