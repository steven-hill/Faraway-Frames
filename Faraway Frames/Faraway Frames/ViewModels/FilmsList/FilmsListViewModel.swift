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
        case content(isUsingArchivedData: Bool)
        case emptySearchResults
        case error(APIError)
        case retrying
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
    init(filmsListService: FilmsListService, imageLoader: ImageLoader, filmSyncService: FilmSyncService) {
        self.filmsListService = filmsListService
        self.imageLoader = imageLoader
        self.filmSyncService = filmSyncService
    }
    
    // MARK: - Methods
    func getAllFilms() async {
        currentState = .loadingAllFilms
        do {
            try Task.checkCancellation()
            let fetchedFilms = try await filmsListService.fetchAllFilms()
            try Task.checkCancellation()
            let syncedFilms = await filmSyncService.syncFilmsWithLocalStorage(fetchedFilms)
            self.films = syncedFilms
            currentState = .content(isUsingArchivedData: filmsListService.isUsingFileManagerData)
            delegate?.didUpdateFilms(films)
            delegate?.didRequestVoiceOverAnnouncement(with: allFilmsMessage)
        } catch {
            guard !Task.isCancelled else { return }
            let networkError = handleFailure(error)
            currentState = .error(networkError)
            delegate?.didFailToLoadFilms()
        }
    }
    
    private func handleFailure(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternetConnection
            case .networkConnectionLost:
                return .networkConnectionLost
            case .timedOut:
                return .networkTimeout
            default:
                return .unknown
            }
        }
        return .unknown
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
            currentState = .emptySearchResults
            delegate?.didFailToMatchResults()
            delegate?.didRequestVoiceOverAnnouncement(with: "No results found. Try another query.")
        } else {
            currentState = .content(isUsingArchivedData: filmsListService.isUsingFileManagerData)
            delegate?.didUpdateFilms(filteredFilms)
            let message = String(format: NSLocalizedString("%d found", comment: ""), filteredFilms.count)
            delegate?.didRequestVoiceOverAnnouncement(with: message)
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
        currentState = .content(isUsingArchivedData: filmsListService.isUsingFileManagerData)
        delegate?.didUpdateFilms(films)
        delegate?.didRequestVoiceOverAnnouncement(with: allFilmsMessage)
    }
    
    func retryLoadingAllFilms() {
        refreshTask?.cancel()
        refreshTask = Task {
            filteredFilms.removeAll()
            currentState = .retrying
            delegate?.didRetry()
            await getAllFilms()
        }
    }
}
