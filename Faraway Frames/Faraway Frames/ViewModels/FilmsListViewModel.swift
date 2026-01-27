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
    var filteredFilms: [Film] = []
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
    
    func filterFilms(by searchText: String) {
        guard !films.isEmpty && !searchText.isEmpty else { return }
        filteredFilms.removeAll()
        let query = cleanSearchText(searchText: searchText)
        guard !query.isEmpty else { return }
        filteredFilms = films.filter { $0.title.lowercased().contains(query) }
        if filteredFilms.isEmpty {
            delegate?.didFailToMatchResults()
        } else {
            delegate?.didUpdateFilms(filteredFilms)
        }
    }
    
    private func cleanSearchText(searchText: String) -> String {
        searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .lowercased()
    }
    
    func resetAllFilms() {
        delegate?.didUpdateFilms(films)
    }
}
