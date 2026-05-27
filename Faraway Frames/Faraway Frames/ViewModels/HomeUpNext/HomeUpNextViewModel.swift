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
        case noFilms
    }
    
    // MARK: - Properties
    private(set) var currentState: HomeUpNextState = .noFilms
    //private(set) var upNextFilms: [Film] = []
    weak var delegate: HomeUpNextViewModelDelegate?
    private let fetchedResultsController: NSFetchedResultsController<FilmMO>
    
    var upNextFilms: [FilmWithStatus] {
        let managedObjects = fetchedResultsController.fetchedObjects ?? []
        return managedObjects.map { mo in
            Film.from(id: mo.id, title: mo.title, originalTitle: mo.originalTitle, originalTitleRomanised: mo.originalTitleRomanised, image: mo.image, movieBanner: mo.movieBanner, filmDescription: mo.filmDescription, director: mo.director, producer: mo.producer, releaseDate: mo.releaseDate, runningTime: mo.runningTime, rottenTomatoesScore: mo.rottenTomatoesScore, url: mo.url, isUpNext: mo.isUpNext, isWatched: mo.isWatched
            )
        }
    }
    
    init(persistentContainer: NSPersistentContainer) {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = NSPredicate(format: "isUpNext == YES")
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    func startFetching() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.upNextFilmsDidChange(upNextFilms)
    }
}
