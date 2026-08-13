//
//  FilmDetailFRCFactory.swift
//  Faraway Frames
//
//  Created by Steven Hill on 27/07/2026.
//

import CoreData

protocol FilmDetailFRCFactory {
    func makeFilmDetailFRC(for filmID: String, context: NSManagedObjectContext) -> NSFetchedResultsController<FilmMO>
}
