//
//  PersistenceControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 28/05/2026.
//

import Testing
import CoreData
@testable import Faraway_Frames

struct PersistenceControllerTests {
    
    @Test func persistenceController_whenLoadingPersistentStoresFails_throwsCorrectError() throws {
        let mockError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true) { container, completion in
                completion(NSPersistentStoreDescription(), mockError)
            }
        }
        
        #expect(thrownError == .loadingStoresFailed(error: mockError))
    }
}
