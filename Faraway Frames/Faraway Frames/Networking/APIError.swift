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
}
