//
//  FilmsListViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 16/01/2026.
//

import UIKit

final class FilmsListViewModel {
    
    private let filmsListService: FilmsListService
    private let imageLoader: ImageLoader
    weak var delegate: FilmsListViewModelDelegate?
    
    private(set) var films: [Film] = []
    var viewModelError: APIError?
    
    init(filmsListService: FilmsListService, imageLoader: ImageLoader) {
        self.filmsListService = filmsListService
        self.imageLoader = imageLoader
    }
    
    func getAllFilms() async {
        do {
            films = try await filmsListService.fetchAllFilms()
            delegate?.didUpdateFilms(films)
        } catch let error as APIError {
            viewModelError = error
            delegate?.didFailToLoadFilms(withError: viewModelError ?? APIError.unknown)
        } catch {
            delegate?.didFailToLoadFilms(withError: APIError.unknown)
        }
    }
    
    func getImage(for film: Film) async -> UIImage? {
        guard let url = URL(string: film.image) else { return nil }
        let image = await imageLoader.loadImage(from: url)
        return image
    }
}
