//
//  FilmQueueService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/06/2026.
//

import Foundation
import CoreData

final class FilmQueueService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func updateFilmStatus(film: Film, queue: FilmQueue, action: QueueAction) async throws -> Bool {
        try await context.perform { [context] in
            let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
            request.predicate = NSPredicate(format: "id == %@", film.id)
            let filmMO: FilmMO
            let existing = try context.fetch(request).first
            
            if existing == nil, case .remove = action {
                return false
            }
            
            if let existing {
                filmMO = existing
            } else {
                filmMO = Film.makeFilmMO(from: film, context: context)
            }
            
            let statusChanged: Bool
            
            switch (queue, action) {
            case (.upNext, .add):
                statusChanged = !filmMO.isUpNext
                filmMO.isUpNext = true
            case (.upNext, .remove):
                statusChanged = filmMO.isUpNext
                filmMO.isUpNext = false
            case (.watched, .add):
                statusChanged = !filmMO.isWatched
                filmMO.isWatched = true
            case (.watched, .remove):
                statusChanged = filmMO.isWatched
                filmMO.isWatched = false
            }
            
            if !filmMO.isUpNext && !filmMO.isWatched {
                context.delete(filmMO)
            }
            
            guard context.hasChanges else { return statusChanged }
            try context.save()
            
            return statusChanged
        }
    }
}
