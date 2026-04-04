//
//  HomeUpNextViewModelUnitTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 26/03/2026.
//

import Testing
@testable import Faraway_Frames

@MainActor
struct HomeUpNextViewModelUnitTests {
    
    @Test func homeUpNextViewModel_currentStateOnInit_isNoFilms() {
        let sut = HomeUpNextViewModel()
        
        #expect(sut.currentState == .noFilms, "Should be `.noFilms` on init.")
    }

    @Test func homeUpNextViewModel_onInit_hasNoFilms() {
        let sut = HomeUpNextViewModel()
        
        #expect(sut.upNextFilms.isEmpty, "Should be empty.")
    }
}
