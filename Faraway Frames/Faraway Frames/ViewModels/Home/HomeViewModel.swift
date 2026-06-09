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
    
    // MARK: - Properties
    private(set) var currentState: HomeState = .idle
    weak var delegate: HomeViewModelDelegate?
    private let upNextFRC: NSFetchedResultsController<FilmMO>
    private let watchedFRC: NSFetchedResultsController<FilmMO>
    private let context: NSManagedObjectContext
    
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
         watchedFRC: NSFetchedResultsController<FilmMO>? = nil
    ) {
        self.context = context
        
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
        } catch let error as NSError {
            currentState = .failure(HomeError(error))
            delegate?.didReceiveError(HomeError(error))
        }
    }
    
    func removeFilmFromQueue(id: String, queue: FilmQueue) async {
        let filmID = id
        let isUpNextTarget = (queue == .upNext)
        
        await context.perform {
            let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
            request.predicate = NSPredicate(format: "id == %@", filmID)
            
            do {
                if let managedObject = try self.context.fetch(request).first {
                    if isUpNextTarget {
                        managedObject.isUpNext = false
                    } else {
                        managedObject.isWatched = false
                    }
                    
                    if !managedObject.isUpNext && !managedObject.isWatched {
                        self.context.delete(managedObject)
                    }
                    
                    if self.context.hasChanges {
                        try self.context.save()
                    }
                }
            } catch {
                Task { @MainActor in
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let homeError = HomeError(error as NSError)
        self.currentState = .failure(homeError)
        self.delegate?.didReceiveError(homeError)
    }
}

// MARK: - Fetched Results Controller Delegate
extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.filmsDidChange(upNextFilms, watchedFilms)
    }
}
