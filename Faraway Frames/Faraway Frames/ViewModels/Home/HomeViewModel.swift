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
    enum HomeUpNextState {
        case idle
    }
    
    // MARK: - Properties
    private(set) var currentState: HomeUpNextState = .idle
    private(set) var upNextFRC: NSFetchedResultsController<FilmMO>
    private(set) var watchedFRC: NSFetchedResultsController<FilmMO>
    
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
}
