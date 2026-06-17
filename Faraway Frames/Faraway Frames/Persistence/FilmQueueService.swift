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
            
            let existing = try context.fetch(request).first
            
            if existing == nil, case .remove = action {
                return false
            }
            return false
        }
    }
}
