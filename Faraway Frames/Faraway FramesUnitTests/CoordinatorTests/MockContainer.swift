//
//  MockContainer.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 03/02/2026.
//

import Foundation
@testable import Faraway_Frames

final class MockContainer: FilmsListServicing, ImageLoading, PersistentStoring {
    func makePersistenceController() throws -> PersistenceControlling {
        return try PersistenceController(inMemory: true)
    }
    
    func makeFilmsListService() -> FilmsListService {
        return MockFilmsListService()
    }
    
    func makeImageLoader() -> ImageLoader {
        return MockImageLoader()
    }
}
