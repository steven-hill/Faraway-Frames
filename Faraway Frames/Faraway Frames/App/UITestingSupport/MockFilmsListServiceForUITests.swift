//
//  MockFilmsListServiceForUITests.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import Foundation

final class MockFilmsListServiceForUITests: FilmsListService {
    let isUsingFileManagerData: Bool
    let shouldSucceed: Bool
    
    init(shouldSucceed: Bool, isUsingFileManagerData: Bool) {
        self.shouldSucceed = shouldSucceed
        self.isUsingFileManagerData = isUsingFileManagerData
    }
    
    func fetchAllFilms() async throws -> [Film] {
        if shouldSucceed == true || isUsingFileManagerData == true {
            return try loadJSON()
        } else {
            throw getMockErrorFromEnvironment()
        }
    }
    
    private func loadJSON() throws -> [Film] {
        guard let url = Bundle.main.url(forResource: "ghibliFilms", withExtension: "json") else {
            fatalError("ghibliFilms JSON file not found")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Film].self, from: data)
        } catch {
            fatalError("ghibliFilms JSON file decoding failed with error: \(error)")
        }
    }
    
    private func getMockErrorFromEnvironment() -> APIError {
        let env = ProcessInfo.processInfo.environment
        guard let type = env["MOCK_ERROR_TYPE"] else { return .unknown }
        
        switch type {
        case "noInternetConnection":
            return .noInternetConnection
        case "networkConnectionLost":
            return .networkConnectionLost
        case "networkTimeout":
            return .networkTimeout
        case "invalidURL":
            return .invalidURL
        case "invalidResponse":
            return .invalidResponse
        case "serverError":
            let code = Int(env["MOCK_ERROR_CODE"] ?? "500") ?? 500
            return .serverError(statusCode: code)
        case "decodingError":
            return .decodingError("")
        default:
            return .unknown
        }
    }
}
