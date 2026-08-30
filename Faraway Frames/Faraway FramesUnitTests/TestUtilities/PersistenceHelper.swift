//
//  PersistenceHelper.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 01/06/2026.
//

import CoreData
@testable import Faraway_Frames
import Testing

struct PersistenceHelper {
    /// Maps a `Film` to a `FilmMO` CoreData entity, and returns it.
    @MainActor static func makeFilmMO(
        with film: Film,
        entity: NSEntityDescription,
        context: NSManagedObjectContext,
        isUpNext: Bool,
        isWatched: Bool
    ) -> FilmMO {
        let filmToBeSaved = FilmMO(entity: entity, insertInto: context)
        filmToBeSaved.id = film.id
        filmToBeSaved.title = film.title
        filmToBeSaved.originalTitle = film.originalTitle
        filmToBeSaved.originalTitleRomanised = film.originalTitleRomanised
        filmToBeSaved.image = film.image
        filmToBeSaved.movieBanner = film.movieBanner
        filmToBeSaved.filmDescription = film.description
        filmToBeSaved.director = film.director
        filmToBeSaved.producer = film.producer
        filmToBeSaved.releaseDate = film.releaseDate
        filmToBeSaved.runningTime = film.runningTime
        filmToBeSaved.rottenTomatoesScore = film.rottenTomatoesScore
        filmToBeSaved.url = film.url
        filmToBeSaved.isUpNext = isUpNext
        filmToBeSaved.isWatched = isWatched
        return filmToBeSaved
    }
    
    /// Used in tests involving CoreData operations error handling.
    nonisolated static var errorScenarios: [(
        systemError: CocoaError,
        expectedReason: PersistenceFailureReason
    )]
    {
        [
            (CocoaError(.fileWriteOutOfSpace), .diskFull),
            (CocoaError(.persistentStoreOpen), .databaseError),
            (CocoaError(.managedObjectReferentialIntegrity), .databaseError),
            (CocoaError(.persistentStoreTypeMismatch), .databaseError),
            (CocoaError(.fileNoSuchFile), .databaseError)
        ]
    }
    
    /// Maps a `Film` to a `FilmMO`, tries to save it in the context, and returns it.
    @MainActor static func saveFilmToDatabase(
        context: NSManagedObjectContext,
        film: Film,
        isUpNext: Bool,
        isWatched: Bool
    ) throws -> FilmMO {
        let entity = try #require(
            NSEntityDescription.entity(
                forEntityName: Persistence.entityname,
                in: context
            ), "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let filmMO = makeFilmMO(
            with: film,
            entity: entity,
            context: context,
            isUpNext: isUpNext,
            isWatched: isWatched
        )
        try? context.save()
        return filmMO
    }
}
