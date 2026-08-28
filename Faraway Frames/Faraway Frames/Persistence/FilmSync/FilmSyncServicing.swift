//
//  FilmSyncServicing.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/08/2026.
//

import Foundation

protocol FilmSyncServicing {
    func syncFilmsWithLocalStorage(_ films: [Film]) async -> [Film]
}
