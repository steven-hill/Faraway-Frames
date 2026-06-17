//
//  HomeVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 22/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit
import CoreData

@MainActor
struct HomeVCTests {
    
    @Test func homeVC_canInitAndLoadView() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func homeVC_setsViewModelDelegateToSelf() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.homeViewModel.delegate != nil, "View model's delegate should be set.")
    }
    
    // MARK: - SUT Helper Method
    private func makeSUT() -> HomeVC {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let mockUpNextFRC = NSFetchedResultsController(
            fetchRequest: FilmMO.upNextFetchRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        let mockWatchedFRC = NSFetchedResultsController(
            fetchRequest: FilmMO.watchedFetchRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        let homeViewModel = HomeViewModel(context: context, upNextFRC: mockUpNextFRC, watchedFRC: mockWatchedFRC, filmQueueService: filmQueueService)
        return HomeVC(homeViewModel: homeViewModel)
    }
}
