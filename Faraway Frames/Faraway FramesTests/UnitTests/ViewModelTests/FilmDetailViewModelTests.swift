//
//  FilmDetailViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 05/02/2026.
//

import Testing
@testable import Faraway_Frames

@MainActor
struct FilmDetailViewModelTests {
    
    @Test func filmDetailViewModel_currentStateOnInit_isNoFilmSelected() {
        let sut = FilmDetailViewModel()
        
        #expect(sut.currentState == .noFilmSelected, "Should be `.noFilmSelected` on init.")
    }

    @Test func filmDetailViewModel_setsCurrentStateToNoFilmSelected_whenFilmIsNil() {
        let sut = FilmDetailViewModel()
        
        sut.updateUI()
        
        #expect(sut.currentState == .noFilmSelected, "Should be `.noFilmSelected` when film is nil.")
    }
    
    @Test func filmDetailViewModel_setsCurrentStateToContent_whenFilmIsPassedIn() {
        let film = Film.sample
        let sut = FilmDetailViewModel(film: film)
        
        sut.updateUI()
        
        #expect(sut.currentState == .content(film), "Should be `.content` when film is provided.")
    }
    
    @Test func filmDetailViewModel_setFilm_updatesCurrentState_whenThereIsAFilm() {
        let film = Film.sample
        let sut = FilmDetailViewModel()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .content(film), "Should update the state to `.content` when a film is set.")
    }
    
    @Test func filmDetailViewModel_setFilm_updatesCurrentState_whenFilmIsNil() {
        let film: Film? = nil
        let sut = FilmDetailViewModel()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .noFilmSelected, "Should update the state to `.noFilmSelected` when a film is nil.")
    }
}
