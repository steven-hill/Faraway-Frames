//
//  MockFilmsListService.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 16/01/2026.
//

import Testing
@testable import Faraway_Frames

struct MockFilmsListService: FilmsListService {
    var result: Result<[Film], APIError>?
    
    func fetchAllFilms() async throws -> [Film] {
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
