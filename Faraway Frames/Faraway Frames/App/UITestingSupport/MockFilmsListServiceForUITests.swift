//
//  MockFilmsListServiceForUITests.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import Foundation

final class MockFilmsListServiceForUITests: FilmsListService {
    func fetchAllFilms() async throws -> [Film] {
        guard let bundle = Bundle(identifier: "com.StevenHill.Faraway-Frames"),
              let url = bundle.url(forResource: "GhibliFilmsUITests", withExtension: "json") else {
            fatalError("ghibliFilms JSON file not found")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Film].self, from: data)
        } catch {
            fatalError("ghibliFilms JSON file decoding failed with error: \(error)")
        }
    }
}
