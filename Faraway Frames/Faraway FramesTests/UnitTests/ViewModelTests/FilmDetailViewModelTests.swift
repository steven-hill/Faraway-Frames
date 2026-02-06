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
        let sut = makeSUT()
        
        #expect(sut.currentState == .noFilmSelected, "Should be `.noFilmSelected` on init.")
    }

    @Test func filmDetailViewModel_setsCurrentStateToNoFilmSelected_whenFilmIsNil() {
        let sut = makeSUT()
        
        sut.updateUI()
        
        #expect(sut.currentState == .noFilmSelected, "Should be `.noFilmSelected` when film is nil.")
    }
    
    @Test func filmDetailViewModel_setsCurrentStateToContent_whenFilmIsPassedIn() {
        let film = Film.sample
        let mockImageLoader = MockImageLoader()
        let sut = FilmDetailViewModel(film: film, imageLoader: mockImageLoader)
        
        sut.updateUI()
        
        #expect(sut.currentState == .content(film), "Should be `.content` when film is provided.")
    }
    
    @Test func filmDetailViewModel_setFilm_updatesCurrentState_whenThereIsAFilm() {
        let film = Film.sample
        let sut = makeSUT()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .content(film), "Should update the state to `.content` when a film is set.")
    }
    
    @Test func filmDetailViewModel_setFilm_updatesCurrentState_whenFilmIsNil() {
        let film: Film? = nil
        let sut = makeSUT()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .noFilmSelected, "Should update the state to `.noFilmSelected` when a film is nil.")
    }
    
    @Test func filmDetailViewModel_getMovieBanner_downloadsMovieBannerImageForFilm() async {
        let film = Film.sample
        let sut = makeSUT()
        
        let movieBanner = await sut.getMovieBanner(for: film)
        
        #expect(movieBanner != nil, "Movie banner should not be nil.")
    }

    @Test func filmDetailViewModel_getMovieBanner_returnsNilWhenFailedToDownloadMovieBannerImage() async {
        let film = Film.sample
        var mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = false
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader)
        
        let movieBanner = await sut.getMovieBanner(for: film)
        
        #expect(movieBanner == nil, "Movie banner should be nil.")
    }
    
    //MARK: - Helper method
    private func makeSUT() -> FilmDetailViewModel {
        let mockImageLoader = MockImageLoader()
        return FilmDetailViewModel(imageLoader: mockImageLoader)
    }
}


