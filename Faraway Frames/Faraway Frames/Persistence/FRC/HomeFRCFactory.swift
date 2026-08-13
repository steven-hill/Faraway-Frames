//
//  HomeFRCFactory.swift
//  Faraway Frames
//
//  Created by Steven Hill on 27/07/2026.
//

import CoreData

protocol HomeFRCFactory {
    func makeHomeUpNextFRC(context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO>
    func makeHomeWatchedFRC(context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO>
}
