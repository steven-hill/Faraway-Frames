//
//  FRCFactory.swift
//  Faraway Frames
//
//  Created by Steven Hill on 27/07/2026.
//

import CoreData

struct FRCFactory: FilmDetailFRCFactory {
    
    func makeHomeUpNextFRC(context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO> {
        let request = FilmMO.upNextFetchRequest()
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    func makeHomeWatchedFRC(context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO> {
        let request = FilmMO.watchedFetchRequest()
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    func makeFilmDetailFRC(for filmID: String, context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO> {
        let request = FilmMO.exploreDetailFetchRequest(using: filmID)
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
}
