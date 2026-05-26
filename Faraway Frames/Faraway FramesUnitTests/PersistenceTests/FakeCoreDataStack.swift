//
//  FakeCoreDataStack.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 26/05/2026.
//

import CoreData

final class FakeCoreDataStack {
    static func makeInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "FarawayFramesCDModel")
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }
}
