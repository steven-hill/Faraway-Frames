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
    
    // MARK: - Queue Definition
    enum FilmQueue {
        case upNext
        case watched
    }
    
    // MARK: - Action Definition
    enum QueueAction {
        case add
        case remove
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
         upNextFRC: NSFetchedResultsController<FilmMO>? = nil,
         watchedFRC: NSFetchedResultsController<FilmMO>? = nil,
         saver: ContextSaving? = nil,
         filmQueueService: FilmQueueService
    ) {
        self.context = context
        self.saver = saver ?? context
        self.filmQueueService = filmQueueService
        
        if let injectedUpNextFRC = upNextFRC {
            self.upNextFRC = injectedUpNextFRC
        } else {
            let request = FilmMO.upNextFetchRequest()
            self.upNextFRC = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
        
        if let injectedWatchedFRC = watchedFRC {
            self.watchedFRC = injectedWatchedFRC
        } else {
            let request = FilmMO.watchedFetchRequest()
            self.watchedFRC = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil, cacheName: nil
            )
        }
        
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
            try await context.perform {
                let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
                request.predicate = NSPredicate(format: "id == %@", film.id)
                
                let filmMO: FilmMO
                let existing = try self.context.fetch(request).first
                
                if existing == nil, case .remove = action {
                    return
                }
                
                if let existing {
                    filmMO = existing
                } else {
                    filmMO = Film.makeFilmMO(from: film, context: self.context)
                }
                
                switch (queue, action) {
                case (.upNext, .add):       filmMO.isUpNext = true
                case (.upNext, .remove):    filmMO.isUpNext = false
                case (.watched, .add):      filmMO.isWatched = true
                case (.watched, .remove):   filmMO.isWatched = false
                }
                
                if !filmMO.isUpNext && !filmMO.isWatched {
                    self.context.delete(filmMO)
                }
                
                guard self.context.hasChanges else { return }
                try self.saver.save()
            }
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
