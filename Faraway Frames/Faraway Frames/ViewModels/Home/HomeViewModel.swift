//
//  HomeViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation
import CoreData

final class HomeViewModel: NSObject, NSFetchedResultsControllerDelegate {
    
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
    
    private var upNextFilms: [FilmWithStatus] {
        let managedObjects = upNextFRC.fetchedObjects ?? []
        return managedObjects.map { mo in
            Film.from(id: mo.id, title: mo.title, originalTitle: mo.originalTitle, originalTitleRomanised: mo.originalTitleRomanised, image: mo.image, movieBanner: mo.movieBanner, filmDescription: mo.filmDescription, director: mo.director, producer: mo.producer, releaseDate: mo.releaseDate, runningTime: mo.runningTime, rottenTomatoesScore: mo.rottenTomatoesScore, url: mo.url, isUpNext: mo.isUpNext, isWatched: mo.isWatched
            )
        }
    }
    
    private var watchedFilms: [FilmWithStatus] {
        let managedObjects = watchedFRC.fetchedObjects ?? []
        return managedObjects.map { mo in
            Film.from(id: mo.id, title: mo.title, originalTitle: mo.originalTitle, originalTitleRomanised: mo.originalTitleRomanised, image: mo.image, movieBanner: mo.movieBanner, filmDescription: mo.filmDescription, director: mo.director, producer: mo.producer, releaseDate: mo.releaseDate, runningTime: mo.runningTime, rottenTomatoesScore: mo.rottenTomatoesScore, url: mo.url, isUpNext: mo.isUpNext, isWatched: mo.isWatched
            )
        }
    }
    
    // MARK: - Initialisation
    init(persistentContainer: NSPersistentContainer,
         upNextFRC: NSFetchedResultsController<FilmMO>? = nil,
         watchedFRC: NSFetchedResultsController<FilmMO>? = nil
    ) {
        let context = persistentContainer.viewContext
        
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
    
    // MARK: - Method
    func performFetches() {
        do {
            try upNextFRC.performFetch()
            try watchedFRC.performFetch()
            currentState = .fetchedObjects
            delegate?.filmsDidChange(upNextFilms, watchedFilms)
        } catch let error as NSError {
            currentState = .failure(HomeError(error))
            delegate?.filmsDidChange([], [])
        }
    }
}
