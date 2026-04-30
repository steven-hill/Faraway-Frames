//
//  FilmsListAPIClient.swift
//  Faraway Frames
//
//  Created by Steven Hill on 12/01/2026.
//

import Foundation

final class FilmsListAPIClient: FilmsListService {
    private let session: NetworkSession
    private let decoder: JSONDecoder
    private let fileManager: FileManaging
    
    init(session: NetworkSession? = nil, decoder: JSONDecoder = JSONDecoder(), fileManager: FileManaging = FileManager.default) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = session ?? URLSession(configuration: config)
        self.decoder = decoder
        self.fileManager = fileManager
    }
    
    func fetchAllFilms() async throws -> [Film] {
        let urlString = "https://ghibliapi.vercel.app/films"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        if let cachedFilms = session.configuration.urlCache?.cachedResponse(for: request),
           let films = try? decodeFilms(from: cachedFilms.data) {
            return films
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw(APIError.serverError(statusCode: httpResponse.statusCode))
        }
        
        saveFilmsDataToFileManager(data: data)
        return try decodeFilms(from: data)
    }
    
    private func decodeFilms(from data: Data) throws -> [Film] {
        do {
            return try decoder.decode([Film].self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    func saveFilmsDataToFileManager(data: Data) {
        if let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appending(path: "ghibliFilms.json") {
            _ = fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        }
    }
}
