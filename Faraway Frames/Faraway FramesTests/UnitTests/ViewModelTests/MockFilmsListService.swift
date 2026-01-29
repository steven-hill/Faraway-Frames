//
//  MockFilmsListService.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 16/01/2026.
//

import Testing
@testable import Faraway_Frames

final class MockFilmsListService: FilmsListService {
    var result: Result<[Film], Error>?
    var fetchWasCalled = false
    
    func fetchAllFilms() async throws -> [Film] {
        fetchWasCalled = true
        switch result {
        case .success(let films):
            return films
        case .failure(let error):
            throw error
        case .none:
            throw APIError.unknown
        }
    }
}
