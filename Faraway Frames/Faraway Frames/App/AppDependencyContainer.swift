//
//  AppDependencyContainer.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/02/2026.
//

import Foundation
import CoreData

final class AppDependencyContainer: FilmsListServicing, ImageLoading, PersistentContainerProtocol {
    private let cacheManager = CacheManager()
    
    func makePersistentContainer() -> NSPersistentContainer {
        let persistentContainer = NSPersistentContainer(name: "FarawayFramesCDModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        return persistentContainer
    }
    
    func makeFilmsListService() -> FilmsListService {
        return FilmsListAPIClient()
    }
    
    func makeImageLoader() -> ImageLoader {
        return APIClientImageLoader(cacheManager: cacheManager)
    }
}
