//
//  HomeUpNextViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 26/03/2026.
//

import Foundation
import CoreData

final class HomeUpNextViewModel: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - State Definition
    enum HomeUpNextState {
        case idle
        case fetchedObjects
        case failure(HomeUpNextError)

        static func == (lhs: HomeUpNextState, rhs: HomeUpNextState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.fetchedObjects, .fetchedObjects):
                return true
            case (.failure(let lhsError), .failure(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Custom Error Definition
    enum HomeUpNextError: Error, Identifiable, Equatable {
        case databaseAccessError
        case diskFull
        case unknown(String)
        
        var id: String { localizedDescription }
        
        var localizedDescription: String {
            switch self {
            case .databaseAccessError:
                return "Unable to access database. Try restarting the app."
            case .diskFull:
                return "Device storage full. Try freeing up some space."
            case .unknown(let message):
                return message
            }
        }

        static func == (lhs: HomeUpNextError, rhs: HomeUpNextError) -> Bool {
            switch (lhs, rhs) {
            case (.databaseAccessError, .databaseAccessError):
                return true
            case (.diskFull, .diskFull):
                return true
            case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties
    private(set) var currentState: HomeUpNextState = .idle
    weak var delegate: HomeUpNextViewModelDelegate?
    private(set) var fetchedResultsController: NSFetchedResultsController<FilmMO>
    
    var upNextFilms: [FilmWithStatus] {
        let managedObjects = fetchedResultsController.fetchedObjects ?? []
        return managedObjects.map { mo in
            Film.from(id: mo.id, title: mo.title, originalTitle: mo.originalTitle, originalTitleRomanised: mo.originalTitleRomanised, image: mo.image, movieBanner: mo.movieBanner, filmDescription: mo.filmDescription, director: mo.director, producer: mo.producer, releaseDate: mo.releaseDate, runningTime: mo.runningTime, rottenTomatoesScore: mo.rottenTomatoesScore, url: mo.url, isUpNext: mo.isUpNext, isWatched: mo.isWatched
            )
        }
    }
    
    // MARK: - Initialisation
    init(persistentContainer: NSPersistentContainer, fetchedResultsController: NSFetchedResultsController<FilmMO>? = nil) {
        let context = persistentContainer.viewContext
        let request = FilmMO.upNextFetchRequest()
        if let injectedController = fetchedResultsController {
            self.fetchedResultsController = injectedController
        } else {
            self.fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: - Methods
    func fetchUpNextFilms() {
        do {
            try fetchedResultsController.performFetch()
            currentState = .fetchedObjects
            delegate?.upNextFilmsDidChange(upNextFilms)
        } catch let error as NSError {
            delegate?.upNextFilmsDidChange([])
            let customError: HomeUpNextError
            if error.domain == NSCocoaErrorDomain && error.code == NSFileWriteOutOfSpaceError {
                customError = .diskFull
            } else if error.domain == NSCocoaErrorDomain {
                customError = .databaseAccessError
            } else {
                customError = .unknown(error.localizedDescription)
            }
            currentState = .failure(customError)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.upNextFilmsDidChange(upNextFilms)
    }
}
