//
//  PersistenceController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/05/2026.
//

import Foundation
import CoreData

final class PersistenceController {
    // MARK: - Core Data stack
    private let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialisation
    init(inMemory: Bool = false,
         storeLoader: ((NSPersistentContainer, @escaping (NSPersistentStoreDescription, Error?) -> Void) -> Void) = { $0.loadPersistentStores(completionHandler: $1) }
    ) throws {
        container = NSPersistentContainer(name: Persistence.persistentContainerName)
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        
        var storesLoadingError: Error?
        storeLoader(container) { _, error in
            if let error = error {
                storesLoadingError = error
            }
        }
        if let error = storesLoadingError {
            throw PersistenceError.loadingStoresFailed(error: error)
        }
    }
    
    // MARK: - Core Data Saving
    func saveContext() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw PersistenceError.savingFailed(error: error)
            }
        }
    }
}
