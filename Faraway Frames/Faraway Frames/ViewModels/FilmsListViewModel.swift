//
//  FilmsListViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 16/01/2026.
//

import UIKit

final class FilmsListViewModel {
    
    enum State {
        case idle
        case success([Film])
        case failure(error: APIError)
    }
    
    private let filmsListService: FilmsListService
    private let imageLoader: ImageLoader
    
    private(set) var films: [Film] = []
    var viewModelError: APIError?
    private(set) var state: State = .idle
    
    init(filmsListService: FilmsListService, imageLoader: ImageLoader) {
        self.filmsListService = filmsListService
        self.imageLoader = imageLoader
    }
    
    func getAllFilms() async throws {
        do {
            films = try await filmsListService.fetchAllFilms()
            state = .success(films)
        } catch let error as APIError {
            viewModelError = error
            state = .failure(error: viewModelError ?? APIError.unknown)
        } catch {
            state = .failure(error: APIError.unknown)
        }
    }
    
    func getImage(for film: Film) async -> UIImage? {
        guard let url = URL(string: film.image) else { return nil }
        let image = await imageLoader.loadImage(from: url)
        return image
    }
}
