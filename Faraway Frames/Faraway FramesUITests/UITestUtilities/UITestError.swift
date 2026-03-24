//
//  UITestError.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 23/02/2026.
//

import Foundation

enum UITestError: Error {
    case noInternetConnection
    case networkTimeout
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case unknown
}
