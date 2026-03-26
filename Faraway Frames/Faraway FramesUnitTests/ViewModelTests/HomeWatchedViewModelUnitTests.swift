//
//  HomeWatchedViewModelUnitTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 26/03/2026.
//

import Testing
@testable import Faraway_Frames

@MainActor
struct HomeWatchedViewModelUnitTests {

    @Test func homeWatchedViewModel_onInit_hasNoFilms() {
        let sut = HomeWatchedViewModel()
        
        #expect(sut.watchedFilms.isEmpty)
    }
}
