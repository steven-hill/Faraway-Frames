//
//  PersistenceHelper.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 01/06/2026.
//

import CoreData
@testable import Faraway_Frames

struct PersistenceHelper {
    @MainActor static func makeFilmMO(with film: Film, entity: NSEntityDescription, context: NSManagedObjectContext, isUpNext: Bool, isWatched: Bool) -> FilmMO {
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
}
