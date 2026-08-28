//
//  FilmSyncService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/06/2026.
//

import CoreData

final class FilmSyncService: FilmSyncServicing {
    private let context: DatabaseContext
    
    init(context: DatabaseContext) {
        self.context = context
    }
    
    func syncFilmsWithLocalStorage(_ films: [Film]) async -> [Film] {
        guard !films.isEmpty else { return [] }
        return await context.perform { [context] in
            let request = NSFetchRequest<FilmMO>(entityName: Persistence.entityname)
            let filmsIDs = films.map { $0.id }
            request.predicate = NSPredicate(format: "id IN %@", filmsIDs)
            
            do {
                let localManagedObjects = try context.fetch(request)
                var localStatusMap: [String: (isUpNext: Bool, isWatched: Bool)] = [:]
                for mo in localManagedObjects {
                    if let id = mo.id {
                        localStatusMap[id] = (isUpNext: mo.isUpNext, isWatched: mo.isWatched)
                    }
                }

                let syncedFilms = films.map { film -> Film in
                    if let localStatus = localStatusMap[film.id] {
                        var updatedFilm = film
                        updatedFilm.isUpNext = localStatus.isUpNext
                        updatedFilm.isWatched = localStatus.isWatched
                        return updatedFilm
                    }
                    return film
                }
                return syncedFilms
            } catch {
                return films
            }
        }
    }
}
