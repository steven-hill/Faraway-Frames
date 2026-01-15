//
//  FilmsListAPIClient.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

final class FilmsListAPIClient: FilmsListService {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetchAllFilms() async throws -> [Film] {
        let urlString = "https://ghibliapi.vercel.app/films"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw(APIError.serverError(statusCode: httpResponse.statusCode))
        }
        
        do {
            let decodedData = try decoder.decode([Film].self, from: data)
            return decodedData
        } catch {
            throw APIError.decodingError
        }
    }
}
