//
//  FilmsListService.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

protocol FilmsListService {
    var isUsingFileManagerData: Bool { get }
    func fetchAllFilms() async throws -> [Film]
}
