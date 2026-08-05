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
    weak var coordinatorDelegate: HomeViewModelCoordinatorDelegate?
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
            #if DEBUG
            try throwErrorForUITests()
            #endif
            
            try upNextFRC.performFetch()
            try watchedFRC.performFetch()
            currentState = .fetchedObjects
            updateFilms()
            delegate?.homeViewModelDidUpdate()
        } catch {
            let reason = PersistenceFailureReason(from: error)
            let homeError = HomeError.fetchFailed(reason)
            handleError(homeError)
        }
    }
    
    func getImage(for film: Film) async -> UIImage? {
        let fallbackImage = SFSymbols.movieClapper
        guard !Task.isCancelled else { return fallbackImage }
        let downloadedImage = await imageLoader.loadImage(for: film.image)
        guard !Task.isCancelled else { return fallbackImage }
        return downloadedImage ?? fallbackImage
    }
    
    func checkCachesForFilmPoster(for film: Film) -> UIImage? {
        return imageLoader.checkCache(for: film.image)
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
        delegate?.homeViewModelDidUpdate()
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
    
    // MARK: - Home View Model Coordinator Delegate Method
    /// A tap on `FilmGridCell` on `HomeVC` flows through here on way to `HomeCoordinator`.
    func selectFilm(at id: Film.ID, in section: FilmQueue) {
        let film: Film?
        if section == .upNext {
            film = upNextFilms.first { $0.id == id }
        } else {
            film = watchedFilms.first { $0.id == id }
        }
        guard let film else { return }
        coordinatorDelegate?.homeViewModelDidCaptureFilm(film)
    }
}

// MARK: - Fetched Results Controller Delegate
extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateFilms()
        if case .failure = currentState {
            currentState = .fetchedObjects
        }
        delegate?.homeViewModelDidUpdate()
    }
}

// MARK: - Extension for setting up UI tests
private extension HomeViewModel {
    private func throwErrorForUITests() throws {
        let env = ProcessInfo.processInfo.environment
        if ProcessInfo.processInfo.isUITestingPersistenceLoadError {
            let failureReason = env["MOCK_CD_FAILURE_REASON"]
            let mappedReason: CocoaError.Code = (failureReason == "databaseError") ? .coreData : .persistentStoreOpen
            throw CocoaError(mappedReason)
        }
    }
}
