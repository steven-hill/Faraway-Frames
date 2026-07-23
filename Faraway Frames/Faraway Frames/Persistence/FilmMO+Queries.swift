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
        return baseFetchRequest(predicate: NSPredicate(format: "isUpNext == YES"))
    }
    
    static func watchedFetchRequest() -> NSFetchRequest<FilmMO> {
        return baseFetchRequest(predicate: NSPredicate(format: "isWatched == YES"))
    }
    
    static func exploreDetailFetchRequest(using filmID: String) -> NSFetchRequest<FilmMO> {
        return baseFetchRequest(predicate: NSPredicate(format: "id == %@", filmID))
    }
    
    // MARK: - Helper
    private static func baseFetchRequest(predicate: NSPredicate) -> NSFetchRequest<FilmMO> {
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = predicate
        return request
    }
}
