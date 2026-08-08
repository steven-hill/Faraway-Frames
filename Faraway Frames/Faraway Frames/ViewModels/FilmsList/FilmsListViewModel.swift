//
//  FilmsListViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 16/01/2026.
//

import UIKit

final class FilmsListViewModel {
    
    // MARK: - State Definition
    enum FilmsListState: Equatable {
        case idle
        case loadingAllFilms
        case content(
            films: [Film],
            isUsingArchivedData: Bool
        )
        case emptySearchResults
        case error(APIError)
    }
    
    // MARK: - Event Definition
    enum FilmsListEvent {
        case voiceOverAnnouncement(String)
    }
    
    // MARK: - Properties
    private let filmsListService: FilmsListService
    private let imageLoader: ImageLoader
    private let filmSyncService: FilmSyncService
    weak var delegate: FilmsListViewModelDelegate?
    private(set) var films: [Film] = []
    private(set) var currentState: FilmsListState = .idle
    private(set) var filteredFilms: [Film] = []
    private(set) var refreshTask: Task<Void, Never>?
    private let allFilmsMessage = "Showing all films"
    
    // MARK: - Initialisation
    init(filmsListService: FilmsListService,
         imageLoader: ImageLoader,
         filmSyncService: FilmSyncService) {
        self.filmsListService = filmsListService
        self.imageLoader = imageLoader
        self.filmSyncService = filmSyncService
    }
    
    // MARK: - Methods
    func getAllFilms() async {
        currentState = .loadingAllFilms
        delegate?.viewModel(self, didChange: currentState)
        do {
            try Task.checkCancellation()
            let fetchedFilms = try await filmsListService.fetchAllFilms()
            try Task.checkCancellation()
            self.films = await filmSyncService.syncFilmsWithLocalStorage(fetchedFilms)
            currentState = .content(
                films: self.films,
                isUsingArchivedData: filmsListService.isUsingFileManagerData
            )
            delegate?.viewModel(self, didChange: currentState)
            delegate?.viewModel(self, didEmit: .voiceOverAnnouncement(allFilmsMessage))
        } catch {
            guard !Task.isCancelled else { return }
            let networkError = APIError(from: error)
            currentState = .error(networkError)
            delegate?.viewModel(self, didChange: currentState)
        }
    }
    
    func getImage(for film: Film) async -> UIImage? {
        let image = await imageLoader.loadImage(for: film.image)
        return image
    }
    
    func filterFilms(by searchText: String) {
        guard !films.isEmpty && !searchText.isEmpty else { return }
        filteredFilms.removeAll()
        let query = cleanSearchText(searchText: searchText)
        guard !query.isEmpty else { return }
        filteredFilms = films.filter { $0.title.lowercased().contains(query) }
        if filteredFilms.isEmpty {
            currentState = .emptySearchResults
            delegate?.viewModel(self, didChange: currentState)
            delegate?.viewModel(self, didEmit: .voiceOverAnnouncement("No results found. Try another query."))
        } else {
            currentState = .content(
                films: filteredFilms,
                isUsingArchivedData: filmsListService.isUsingFileManagerData
            )
            delegate?.viewModel(self, didChange: currentState)
            let message = String(format: NSLocalizedString("%d found", comment: ""), filteredFilms.count)
            delegate?.viewModel(self, didEmit: .voiceOverAnnouncement(message))
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
        filteredFilms.removeAll()
        currentState = .content(
            films: films,
            isUsingArchivedData: filmsListService.isUsingFileManagerData
        )
        delegate?.viewModel(self, didChange: currentState)
        delegate?.viewModel(self, didEmit: .voiceOverAnnouncement(allFilmsMessage))
    }
    
    func retryLoadingAllFilms() {
        refreshTask?.cancel()
        filteredFilms.removeAll()
        currentState = .loadingAllFilms
        delegate?.viewModel(self, didChange: currentState)
        refreshTask = Task {
            await getAllFilms()
        }
    }
    
    func syncFilmWithDatabase(_ film: Film) async -> Film {
        return await filmSyncService.syncSingleFilmWithLocalStorage(film)
    }
    
    func updateFilmInArrays(_ updatedFilm: Film) {
        if let masterIndex = films.firstIndex(where: { $0.id == updatedFilm.id }) {
            films[masterIndex] = updatedFilm
            currentState = .content(
                films: films,
                isUsingArchivedData: filmsListService.isUsingFileManagerData
            )
            delegate?.viewModel(self, didChange: currentState)
        }
        
        if let filteredIndex = filteredFilms.firstIndex(where: { $0.id == updatedFilm.id }) {
            filteredFilms[filteredIndex] = updatedFilm
            currentState = .content(
                films: filteredFilms,
                isUsingArchivedData: filmsListService.isUsingFileManagerData
            )
            delegate?.viewModel(self, didChange: currentState)
        }
    }
}
