//
//  FilmSyncService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/06/2026.
//

import Foundation

final class FilmSyncService {
    func syncFilmsWithLocalStorage(_ films: [Film]) async -> [Film] {
        guard !films.isEmpty else { return [] }
        return films
    }
}
