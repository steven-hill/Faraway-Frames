//
//  ThrowingFetchedResultsController.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 27/07/2026.
//

import CoreData
@testable import Faraway_Frames

/// Used in tests for fetch failure.
final class ThrowingFetchedResultsController: NSFetchedResultsController<FilmMO> {
    let errorToThrow: Error
    
    init(context: NSManagedObjectContext, errorToThrow: Error) {
        self.errorToThrow = errorToThrow
        
        let validRequest = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        validRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        super.init(
            fetchRequest: validRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    override func performFetch() throws {
        throw errorToThrow
    }
}
