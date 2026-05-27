//
//  MockContainer.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 03/02/2026.
//

import Foundation
@testable import Faraway_Frames
import CoreData

final class MockContainer: FilmsListServicing, ImageLoading, PersistentContainerProtocol {
    func makeFilmsListService() -> FilmsListService {
        return MockFilmsListService()
    }
    
    func makeImageLoader() -> ImageLoader {
        return MockImageLoader()
    }
    
    func makePersistentContainer() -> NSPersistentContainer {
        return FakeCoreDataStack.makeInMemoryContainer()
    }
}
