//
//  HomeViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData
import UIKit

final class HomeViewModel: NSObject {
    
    // MARK: - State Definition
    enum HomeState: Equatable {
        case idle
        case fetchedObjects
        case failure(HomeError)
    }
    
    // MARK: - Properties
    private(set) var currentState: HomeState = .idle
    weak var delegate: HomeViewModelDelegate?
    private let upNextFRC: NSFetchedResultsController<FilmMO>
    private let watchedFRC: NSFetchedResultsController<FilmMO>
    private let imageLoader: ImageLoader
    private let filmQueueService: FilmQueueService
    private(set) var upNextFilms: [Film] = []
    private(set) var watchedFilms: [Film] = []
    
    // MARK: - Initialisation
    init(
         upNextFRC: NSFetchedResultsController<FilmMO>,
         watchedFRC: NSFetchedResultsController<FilmMO>,
         imageLoader: ImageLoader,
         filmQueueService: FilmQueueService
    ) {
        self.upNextFRC = upNextFRC
        self.watchedFRC = watchedFRC
        self.imageLoader = imageLoader
        self.filmQueueService = filmQueueService
        super.init()
        self.upNextFRC.delegate = self
        self.watchedFRC.delegate = self
    }
    
    // MARK: - Methods
    func performFetches() {
        do {
            try upNextFRC.performFetch()
            try watchedFRC.performFetch()
            currentState = .fetchedObjects
            updateFilms()
            delegate?.filmsDidChange(upNextFilms, watchedFilms)
        } catch {
            let reason = PersistenceFailureReason(from: error)
            let homeError = HomeError.fetchFailed(reason)
            handleError(homeError)
        }
    }
    
    func getImage(for film: Film) async -> UIImage? {
        let fallbackImage = SFSymbols.movieClapper
        guard let url = URL(string: film.image) else {
            return fallbackImage
        }
        let downloadedImage = await imageLoader.loadImage(from: url)
        return downloadedImage ?? fallbackImage
    }
    
    func toggleFilmInQueue(film: Film, queue: FilmQueue, action: QueueAction) async {
        do {
            try await filmQueueService.updateFilmStatus(film: film, queue: queue, action: action)
        } catch {
            let reason = PersistenceFailureReason(from: error)
            let homeError = action == .add ? HomeError.addFailed(reason) : HomeError.removeFailed(reason)
            handleError(homeError)
        }
    }

    private func handleError(_ homeError: HomeError) {
        currentState = .failure(homeError)
        delegate?.didReceiveError(homeError)
    }
    
    // MARK: - Helper Methods
    private func updateFilms() {
        let upNextObjects = upNextFRC.fetchedObjects ?? []
        self.upNextFilms = upNextObjects.map { Film(from: $0) }
        
        let watchedObjects = watchedFRC.fetchedObjects ?? []
        self.watchedFilms = watchedObjects.map { Film(from: $0) }
    }
    
    func lookupUpNextFilm(for id: String) -> Film? {
        return upNextFilms.first { $0.id == id }
    }
    
    func lookupWatchedFilm(for id: String) -> Film? {
        return watchedFilms.first { $0.id == id }
    }
}

// MARK: - Fetched Results Controller Delegate
extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateFilms()
        delegate?.filmsDidChange(upNextFilms, watchedFilms)
    }
}
