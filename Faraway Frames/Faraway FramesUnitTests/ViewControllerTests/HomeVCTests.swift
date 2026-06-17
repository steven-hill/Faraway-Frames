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
    
    // MARK: - SUT Helper Method
    private func makeSUT() -> HomeVC {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let homeViewModel = HomeViewModel(context: testPersistenceController.viewContext, filmQueueService: filmQueueService)
        return HomeVC(homeViewModel: homeViewModel)
    }
}
