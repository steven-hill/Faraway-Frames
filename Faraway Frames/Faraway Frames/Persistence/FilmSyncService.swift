//
//  FilmSyncService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/06/2026.
//

import CoreData

final class FilmSyncService {
    private let context: DatabaseContext
    
    init(context: DatabaseContext) {
        self.context = context
    }
    
    func syncFilmsWithLocalStorage(_ films: [Film]) async -> [Film] {
        guard !films.isEmpty else { return [] }
        return await context.perform { [context] in
            let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
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
    
    func syncSingleFilmWithLocalStorage(_ film: Film) async -> Film {
        await context.perform {
            let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
            request.predicate = NSPredicate(format: "id == %@", film.id)
            request.fetchLimit = 1
            
            do {
                if let localMO = try self.context.fetch(request).first {
                    var updatedFilm = film
                    updatedFilm.isUpNext = localMO.isUpNext
                    updatedFilm.isWatched = localMO.isWatched
                    return updatedFilm
                }
                return film
            } catch {
                return film
            }
        }
    }
}
