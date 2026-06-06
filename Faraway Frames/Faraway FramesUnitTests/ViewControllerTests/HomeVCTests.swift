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

    @Test func homeVC_canInitAndLoadView() throws {
        let sut = try makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func homeVC_setsViewModelDelegateToSelf() throws {
        let sut = try makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.homeViewModel.delegate != nil, "View model's delegate should be set.")
    }
        
    // MARK: - SUT Helper Method
    private func makeSUT() throws -> HomeVC {
        let persistenceController = try PersistenceController(inMemory: true)
        let homeViewModel = HomeViewModel(persistentContainer: persistenceController.container)
        return HomeVC(homeViewModel: homeViewModel)
    }
}
