//
//  AppDependencyContainer.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/02/2026.
//

import Foundation

final class AppDependencyContainer: FilmsListServicing, ImageLoading {
    private let cacheManager = CacheManager()
    
    func makeFilmsListService() -> FilmsListService {
        return FilmsListAPIClient()
    }
    
    func makeImageLoader() -> ImageLoader {
        return APIClientImageLoader(cacheManager: cacheManager)
    }
}
