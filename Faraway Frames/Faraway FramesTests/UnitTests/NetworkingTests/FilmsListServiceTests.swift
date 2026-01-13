//
//  FilmsListServiceTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation
import Testing
@testable import Faraway_Frames

struct FilmsListServiceTests {
    
    @Test func fetchAllFilms_throwsError_onInvalidURL() async throws {
        var mockFilmsListService = MockFilmsListService()
        mockFilmsListService.mockError = APIError.invalidURL
        let films = try await mockFilmsListService.fetchAllFilms()
        
        #expect(films.isEmpty)
        #expect(mockFilmsListService.mockError != nil)
        #expect(mockFilmsListService.mockError == .invalidURL)
    }
}
