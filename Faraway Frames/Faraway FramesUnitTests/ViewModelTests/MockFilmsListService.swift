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
    private var continuation: CheckedContinuation<[Film], Error>?
    var shouldPauseForLoadingStateTest = false
    
    func fetchAllFilms() async throws -> [Film] {
        fetchWasCalled = true
        
        if shouldPauseForLoadingStateTest {
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }
        
        switch result {
        case .success(let films):
            return films
        case .failure(let error):
            throw error
        case .none:
            throw APIError.unknown
        }
    }
    
    func resume() {
        switch result {
        case .success(let films): continuation?.resume(returning: films)
        case .failure(let error): continuation?.resume(throwing: error)
        case .none: continuation?.resume(throwing: APIError.unknown)
        }
    }
}
