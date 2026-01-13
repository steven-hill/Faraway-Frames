//
//  FilmsListAPIClient.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

struct FilmsListAPIClient: FilmsListService {
    private let urlString = "https://ghibliapi.vercel.app/films"
    
    func fetchAllFilms() async throws -> [Film] {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        return []
    }
}



