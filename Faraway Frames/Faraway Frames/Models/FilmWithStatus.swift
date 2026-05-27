//
//  FilmWithStatus.swift
//  Faraway Frames
//
//  Created by Steven Hill on 27/05/2026.
//

import Foundation
import CoreData

/// A thread-safe, Sendable wrapper that combines a core Film entity with user-specific storage flags.
struct FilmWithStatus: Hashable, Identifiable, Sendable {
    var id: String { film.id }
    
    let film: Film
    let isUpNext: Bool
    let isWatched: Bool
    
    init(film: Film, isUpNext: Bool, isWatched: Bool) {
        self.film = film
        self.isUpNext = isUpNext
        self.isWatched = isWatched
    }
}

// Extension to map raw database variables to your clean domain structure
extension Film {
    /// Maps a managed object's fields directly into a thread-safe FilmWithStatus wrapper.
    /// This decouples the type system from Core Data's background internal files.
    static func from(
        id: String?, title: String?, originalTitle: String?, originalTitleRomanised: String?,
        image: String?, movieBanner: String?, filmDescription: String?, director: String?,
        producer: String?, releaseDate: String?, runningTime: String?, rottenTomatoesScore: String?,
        url: String?, isUpNext: Bool, isWatched: Bool
    ) -> FilmWithStatus {
        let domainFilm = Film(
            id: id ?? "",
            title: title ?? "Unknown Title",
            originalTitle: originalTitle ?? "",
            originalTitleRomanised: originalTitleRomanised ?? "",
            image: image ?? "",
            movieBanner: movieBanner ?? "",
            description: filmDescription ?? "",
            director: director ?? "",
            producer: producer ?? "",
            releaseDate: releaseDate ?? "",
            runningTime: runningTime ?? "",
            rottenTomatoesScore: rottenTomatoesScore ?? "",
            url: url ?? ""
        )
        return FilmWithStatus(film: domainFilm, isUpNext: isUpNext, isWatched: isWatched)
    }
}
