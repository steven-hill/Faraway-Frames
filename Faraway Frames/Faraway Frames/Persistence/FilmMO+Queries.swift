//
//  FilmMO+Queries.swift
//  Faraway Frames
//
//  Created by Steven Hill on 31/05/2026.
//

import CoreData

extension FilmMO {
    static func upNextFetchRequest() -> NSFetchRequest<FilmMO> {
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = NSPredicate(format: "isUpNext == YES")
        return request
    }
}
