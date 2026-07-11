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
    
    @Test("Empty state is displayed when `Up Next` segment is empty.")
    func homeVC_whenUpNextIsEmpty_displaysUpNextEmptyState() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config != nil, "Should be displaying content unavailable view for Up Next films.")
    }
    
    @Test("Empty state is displayed when `Watched` segment is empty.")
    func homeVC_whenWatchedIsEmpty_displaysWatchedEmptyState() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.segmentedControl.selectedSegmentIndex = 1
        sut.segmentedControl.sendActions(for: .valueChanged)
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config != nil, "Should be displaying content unavailable view.")
    }
    
    @Test("Films added to Up Next appear in Up Next segment")
    func homeVC_whenFilmWasAddedToUpNext_onInit_displaysInUpNext() throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let homeVM = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            filmQueueService: filmQueueService)
        let sut = HomeVC(homeViewModel: homeVM)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        
        sut.loadViewIfNeeded()
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config == nil, "Should be displaying Up Next films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 1, "Should be one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the film that was added.")
    }
    
    // MARK: - SUT Helper Method
    private func makeSUT() -> HomeVC {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let homeViewModel = HomeViewModel(upNextFRC: mockUpNextFRC, watchedFRC: mockWatchedFRC, filmQueueService: filmQueueService)
        return HomeVC(homeViewModel: homeViewModel)
    }
}
