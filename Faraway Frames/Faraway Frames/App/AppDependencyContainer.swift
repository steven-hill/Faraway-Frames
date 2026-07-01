//
//  AppDependencyContainer.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/02/2026.
//

import Foundation

final class AppDependencyContainer: FilmsListServicing, ImageLoading, PersistentStoring, AccessibilityServicing {
    private let cacheManager = CacheManager()
    
    func makePersistenceController() throws -> PersistenceControlling {
        return try PersistenceController(inMemory: false)
    }
    
    func makeFilmsListService() -> FilmsListService {
        return FilmsListAPIClient()
    }
    
    func makeImageLoader() -> ImageLoader {
        return APIClientImageLoader(cacheManager: cacheManager)
    }
    
    func makeAccessibilityService() -> AccessibilityService {
        return DefaultAccessibilityService()
    }
}
