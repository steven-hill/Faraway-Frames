//
//  HomeVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 22/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

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
