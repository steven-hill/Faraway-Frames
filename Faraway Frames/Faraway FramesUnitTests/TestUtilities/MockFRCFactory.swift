//
//  MockFRCFactory.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 27/07/2026.
//

@testable import Faraway_Frames
import CoreData

struct MockFRCFactory: HomeFRCFactory, FilmDetailFRCFactory {
    var makeFilmDetailFRCStub: ((String, NSManagedObjectContext) -> NSFetchedResultsController<FilmMO>)?
    
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
        if let stub = makeFilmDetailFRCStub {
            return stub(filmID, context)
        }
        let request = FilmMO.exploreDetailFetchRequest(using: filmID)
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
}
