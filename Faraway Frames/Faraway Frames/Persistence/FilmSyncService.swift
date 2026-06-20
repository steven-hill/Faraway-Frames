//
//  FilmSyncService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/06/2026.
//

import Foundation
import CoreData

final class FilmSyncService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func syncFilmsWithLocalStorage(_ films: [Film]) async -> [Film] {
        guard !films.isEmpty else { return [] }
        return films
    }
}
