//
//  PersistenceController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/05/2026.
//

import Foundation
import CoreData

final class PersistenceController: PersistenceControlling {
    // MARK: - Core Data stack
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialisation
    init(inMemory: Bool = false,
         containerName: String = Persistence.persistentContainerName,
         storeLoader: ((NSPersistentContainer, @escaping (NSPersistentStoreDescription, Error?) -> Void) -> Void) = { $0.loadPersistentStores(completionHandler: $1) }
    ) throws {
        let bundle = Bundle(for: Self.self)
        guard bundle.url(forResource: containerName, withExtension: "momd") != nil else {
            let error = NSError(
                domain: NSCocoaErrorDomain,
                code: NSFileReadNoSuchFileError,
                userInfo: [NSLocalizedDescriptionKey: "Failed to locate the .momd file for the container"])
            throw PersistenceError.loadingStoresFailed(error: error)
        }
        
        container = NSPersistentContainer(name: containerName)
        
        let isUITesting = ProcessInfo.processInfo.isUITestingMockPersistenceData
        if inMemory || isUITesting {
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
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        if isUITesting {
            createMockMO(context: viewContext)
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

extension PersistenceController {
    private func createMockMO(context: NSManagedObjectContext) {
        let mockMO = Film.makeFilmMO(from: Film.sample[0], context: context)
        mockMO.isUpNext = true
        try? context.save()
    }
}
