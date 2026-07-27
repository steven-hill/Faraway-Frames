//
//  FRCFactory.swift
//  Faraway Frames
//
//  Created by Steven Hill on 27/07/2026.
//

import CoreData

struct FRCFactory: FilmDetailFRCFactory {
    func makeFilmDetailFRC(for filmID: String, context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO> {
        let request = FilmMO.exploreDetailFetchRequest(using: filmID)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
