//
//  PersistenceControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 28/05/2026.
//

import Testing
import CoreData

struct PersistenceControllerTests {

    @Test func persistenceController_canInit() throws {
        let sut = try PersistenceController(inMemory: true)
        #expect(sut.persistenceError == .none)
    }
    
    @Test func persistenceController_whenLoadingPersistentStoresFails_throwsError() throws {
        let sut = try PersistenceController(inMemory: true, containerName: "ErrorContainer")
        #expect(sut.persistenceError == .loadingStoreFailed)
    }
}
