//
//  HomeViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData

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
    private let context: NSManagedObjectContext
    private let saver: ContextSaving
    private let filmQueueService: FilmQueueService
    
    private var upNextFilms: [Film] {
        let managedObjects = upNextFRC.fetchedObjects ?? []
        return managedObjects.map { Film(from: $0) }
    }
    
    private var watchedFilms: [Film] {
        let managedObjects = watchedFRC.fetchedObjects ?? []
        return managedObjects.map { Film(from: $0) }
    }
    
    // MARK: - Initialisation
    init(context: NSManagedObjectContext,
         upNextFRC: NSFetchedResultsController<FilmMO>,
         watchedFRC: NSFetchedResultsController<FilmMO>,
         saver: ContextSaving? = nil,
         filmQueueService: FilmQueueService
    ) {
        self.context = context
        self.upNextFRC = upNextFRC
        self.watchedFRC = watchedFRC
        self.saver = saver ?? context
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
            delegate?.filmsDidChange(upNextFilms, watchedFilms)
        } catch {
            let homeError = HomeError.fetch(error)
            handleError(homeError)
        }
    }
    
    func toggleFilmInQueue(film: Film, queue: FilmQueue, action: QueueAction) async {
        do {
            try await filmQueueService.updateFilmStatus(film: film, queue: queue, action: action)
        } catch {
            let homeError = action == .add ? HomeError.add(error) : HomeError.delete(error)
            handleError(homeError)
        }
    }

    private func handleError(_ homeError: HomeError) {
        currentState = .failure(homeError)
        delegate?.didReceiveError(homeError)
    }
}

// MARK: - Fetched Results Controller Delegate
extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.filmsDidChange(upNextFilms, watchedFilms)
    }
}
