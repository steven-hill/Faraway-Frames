//
//  FilmMO+Queries.swift
//  Faraway Frames
//
//  Created by Steven Hill on 31/05/2026.
//

import CoreData

extension FilmMO {
    // MARK: - Fetch Requests
    static func upNextFetchRequest() -> NSFetchRequest<FilmMO> {
        return createFetchRequest(sortKey: "dateAddedToUpNext",
                                  predicate: NSPredicate(format:"isUpNext == YES"),
                                  ascending: true)
    }
    
    static func watchedFetchRequest() -> NSFetchRequest<FilmMO> {
        return createFetchRequest(sortKey: "dateAddedToWatched",
                                  predicate: NSPredicate(format: "isWatched == YES"),
                                  ascending: true)
    }
    
    static func exploreDetailFetchRequest(using filmID: String) -> NSFetchRequest<FilmMO> {
        return createFetchRequest(
            sortKey: "title",
            predicate: NSPredicate(format: "id == %@", filmID),
            ascending: true
        )
    }
    
    // MARK: - Helper
    private static func createFetchRequest(
        sortKey: String,
        predicate: NSPredicate,
        ascending: Bool
    ) -> NSFetchRequest<FilmMO> {
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: ascending)]
        request.predicate = predicate
        return request
    }
}
