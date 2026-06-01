//
//  MockDependencies.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import Foundation

final class MockDependencies: FilmsListServicing, ImageLoading, PersistentStoring {
    private let shouldSucceed: Bool = ProcessInfo.processInfo.isUITestingMockNetworkSuccess
    private let isUsingFileManagerData: Bool = ProcessInfo.processInfo.isUITestingMockNetworkFailureWithFileManagerData
    
    func makeFilmsListService() -> FilmsListService {
        return MockFilmsListServiceForUITests(shouldSucceed: shouldSucceed, isUsingFileManagerData: isUsingFileManagerData)
    }
    
    func makeImageLoader() -> ImageLoader {
        return MockImageLoaderForUITests()
    }
    
    func makePersistenceController() throws -> PersistenceControlling {
        return try PersistenceController(inMemory: true)
    }
}
