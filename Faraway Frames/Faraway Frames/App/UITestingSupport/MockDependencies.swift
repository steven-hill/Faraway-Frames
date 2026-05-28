//
//  MockDependencies.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import Foundation
import CoreData

final class MockDependencies: FilmsListServicing, ImageLoading, PersistentContainerProtocol {
    private let shouldSucceed: Bool = ProcessInfo.processInfo.isUITestingMockNetworkSuccess
    private let isUsingFileManagerData: Bool = ProcessInfo.processInfo.isUITestingMockNetworkFailureWithFileManagerData
    
    func makeFilmsListService() -> FilmsListService {
        return MockFilmsListServiceForUITests(shouldSucceed: shouldSucceed, isUsingFileManagerData: isUsingFileManagerData)
    }
    
    func makeImageLoader() -> ImageLoader {
        return MockImageLoaderForUITests()
    }
    
    func makePersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: Persistence.persistentContainerName)
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }
}
