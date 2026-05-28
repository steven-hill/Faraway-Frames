//
//  PersistenceController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/05/2026.
//

import Foundation
import CoreData

final class PersistenceController {
    // MARK: - Persistence Error
    enum PersistenceError: Error {
        case none
    }
    
    // MARK: - Properties
    private(set) var persistenceError: PersistenceError = .none
    
    // MARK: - Core Data stack
    private let container: NSPersistentContainer
    
    // MARK: - Initialisation
    init(inMemory: Bool = false, containerName: String = "FarawayFramesCDModel") throws {
        container = NSPersistentContainer(name: containerName)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
