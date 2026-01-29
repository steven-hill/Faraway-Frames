//
//  Helpers.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 19/01/2026.
//

import Foundation
import Testing
@testable import Faraway_Frames

struct MockServiceHelper {
    static func setupMockServiceForSuccessCase() -> MockFilmsListService {
        let mockService = MockFilmsListService()
        let films = try! JSONHelper.loadAndDecodeFilmsFromJSON() 
        mockService.result = .success(films)
        return mockService
    }
}

struct JSONHelper {
   static func loadAndDecodeFilmsFromJSON() throws -> [Film] {
       guard let bundle = Bundle(identifier: "com.StevenHill.Faraway-FramesTests"),
             let url = bundle.url(forResource: "ghibliFilms", withExtension: "json") else {
           Issue.record("ghibliFilms JSON file not found")
           return []
       }
       do {
           let data = try Data(contentsOf: url)
           return try JSONDecoder().decode([Film].self, from: data)
       } catch {
           Issue.record("ghibliFilms JSON file decoding failed with error: \(error)")
           return []
       }
   }
}

struct MockSession {
    static func createMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
