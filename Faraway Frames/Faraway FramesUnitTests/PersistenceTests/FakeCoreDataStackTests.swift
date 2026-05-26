//
//  FakeCoreDataStackTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 26/05/2026.
//

import Testing
import CoreData

struct FakeCoreDataStackTests {

    @Test("Verify test stack runs in-memory")
    func fakeCoreDataStack_configuresInMemoryContainerAndStoresItInNullDirectory() {
        let container = FakeCoreDataStack.makeInMemoryContainer()
        #expect(container.persistentStoreDescriptions.isEmpty == false, "Should not be empty.")
        
        let firstStoreURL = container.persistentStoreDescriptions.first?.url?.absoluteString
        #expect(firstStoreURL == "file:///dev/null", "Should point to in-memory null directory.")
    }
}
