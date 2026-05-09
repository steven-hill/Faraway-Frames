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
    private var fileURL: URL? {
        fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appending(path: Paths.folderPath)
            .appending(path: Paths.filePath)
    }
    
    init(session: NetworkSession? = nil, decoder: JSONDecoder = JSONDecoder(), fileManager: FileManaging = FileManager.default) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 60
        self.session = session ?? URLSession(configuration: config)
        self.decoder = decoder
        self.fileManager = fileManager
    }
    
    func fetchAllFilms() async throws -> [Film] {
        let urlString = GhibliAPI.allFilmsURLString
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw(APIError.serverError(statusCode: httpResponse.statusCode))
            }
            
            saveFilmsDataToFileManager(data: data)
            return try decodeFilms(from: data)
        } catch {
                if let dataInFileManager = loadFilmsDataFromFileManager() {
                    return try decodeFilms(from: dataInFileManager)
                }
            throw error
        }
    }
    
    private func decodeFilms(from data: Data) throws -> [Film] {
        do {
            return try decoder.decode([Film].self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    func saveFilmsDataToFileManager(data: Data) {
        guard let fileURL = fileURL else { return }
        let folderURL = fileURL.deletingLastPathComponent()
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.write(data: data, to: fileURL, options: .atomic)
        } catch {
            print("DEBUG: Failed to save to FM: \(error.localizedDescription)")
        }
    }
    
    func loadFilmsDataFromFileManager() -> Data? {
        guard let fileURL = fileURL, fileManager.fileExists(atPath: fileURL.path) else { return nil }
        return try? fileManager.read(from: fileURL)
    }
}
