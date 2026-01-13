//
//  MockFilmsListService.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation
@testable import Faraway_Frames

struct MockFilmsListService: FilmsListService {
    var mockError: APIError?
    
    func fetchAllFilms() async throws -> [Film] {
        []
    }
}
