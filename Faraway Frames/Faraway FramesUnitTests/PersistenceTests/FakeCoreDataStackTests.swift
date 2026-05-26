//
//  FakeCoreDataStackTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 26/05/2026.
//

import Testing

struct FakeCoreDataStackTests {

    @Test("Verify test stack runs in-memory")
    func fakeCoreDataStack_configuresInMemoryContainerAndStoresItInNullDirectory() {
        let container = FakeCoreDataStack.makeInMemoryContainer()
        #expect(container.persistentStoreDescriptions.isEmpty == false, "Should not be empty.")
        
        let firstStoreURL = container.persistentStoreCoordinator.persistentStores.first?.url?.absoluteURL
        #expect(firstStoreURL == "file:///dev/null", "Should point to in-memory null directory.")
    }
}
