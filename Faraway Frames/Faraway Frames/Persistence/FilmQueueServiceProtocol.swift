//
//  FilmQueueServiceProtocol.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/07/2026.
//

import Foundation

protocol FilmQueueServiceProtocol {
    func updateFilmStatus(film: Film, queue: FilmQueue, action: QueueAction) async throws -> Bool
}
