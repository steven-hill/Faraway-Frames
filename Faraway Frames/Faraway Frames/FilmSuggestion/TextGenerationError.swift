//
//  TextGenerationError.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/08/2026.
//

import Foundation

/// Custom error to use instead of `LanguageModelSession.GenerationError`.
enum TextGenerationError: LocalizedError {
    case contextWindowExceeded
    case localAssetsMissing
    case contentBlockedByGuardrails
    case languageNotSupported
    case rateLimited
    case systemOverloaded
    case outputParsingFailed
    case requestRefused
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .contextWindowExceeded:
            return "The request was too long. Please try again."
        case .localAssetsMissing:
            return "The model is temporarily unavailable. Please try again shortly."
        case .contentBlockedByGuardrails:
            return "The request or response violates safety guidelines."
        case .languageNotSupported:
            return "This language or region is currently unsupported."
        case .rateLimited, .systemOverloaded:
            return "Busy processing requests. Please wait a moment."
        case .outputParsingFailed, .requestRefused, .unknown:
            return "An unexpected error occurred while generating content."
        }
    }
}
