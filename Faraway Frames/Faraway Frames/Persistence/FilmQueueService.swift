//
//  FilmQueueService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/06/2026.
//

import Foundation
import CoreData

final class FilmQueueService: FilmQueueServiceProtocol {
    private let context: NSManagedObjectContext
    private let saver: ContextSaving
    
    init(context: NSManagedObjectContext, saver: ContextSaving? = nil) {
        self.context = context
        self.saver = saver ?? context
    }
    
    @discardableResult
    func updateFilmStatus(film: Film, queue: FilmQueue, action: QueueAction) async throws -> Bool {
        try await context.perform { [context, saver] in
            let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
            request.predicate = NSPredicate(format: "id == %@", film.id)
            let existing = try context.fetch(request).first
            if existing == nil, case .remove = action {
                return false
            }
            let filmMO = existing ?? Film.makeFilmMO(from: film, context: context)
            
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
            try saver.save()
            
            return statusChanged
        }
    }
}
