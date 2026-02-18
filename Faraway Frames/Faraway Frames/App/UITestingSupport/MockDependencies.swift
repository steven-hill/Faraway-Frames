//
//  MockDependencies.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//


import Foundation

final class MockDependencies: FilmsListServicing, ImageLoading {
    func makeFilmsListService() -> FilmsListService {
        return MockFilmsListServiceForUITests()
    }
    
    func makeImageLoader() -> ImageLoader {
        return MockImageLoaderForUITests()
    }
}

