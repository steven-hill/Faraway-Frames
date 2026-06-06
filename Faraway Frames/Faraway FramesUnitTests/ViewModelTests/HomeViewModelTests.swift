//
//  HomeViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 06/06/2026.
//

import Testing
@testable import Faraway_Frames
import CoreData

@MainActor
struct HomeViewModelTests {

    @Test("`currentState` is correct on init")
    func homeViewModel_currentStateOnInit_isIdle() throws {
        let persistenceController = try PersistenceController(inMemory: true)
        let sut = HomeViewModel(persistentContainer: persistenceController.container)
        
        #expect(sut.currentState == .idle, "Should be `.idle` on init.")
    }
}
