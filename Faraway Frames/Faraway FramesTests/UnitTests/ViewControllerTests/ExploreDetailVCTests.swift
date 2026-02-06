//
//  ExploreDetailVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 05/02/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct ExploreDetailVCTests {

    @Test func exploreDetailVC_canInit_withFilm() {
        let sut = makeSUTWithNilFilm()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_canInit_whenFilmIsNil() {
        let sut = makeSUTWithNilFilm()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_setsDelegate() {
        let sut = makeSUTWithNilFilm()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.filmDetailViewModel.delegate != nil, "Should set the delegate.")
    }

    @Test func exploreDetailVC_viewDidLoad_displaysFilmWhenFilmIsProvided() {
        let film = Film.sample
        let mockImageLoader = MockImageLoader()
        let filmDetailViewModel = FilmDetailViewModel(film: film, imageLoader: mockImageLoader)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.title == film.title, "Titles should match.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_displaysEmptyStateWhenFilmIsNil() {
        let sut = makeSUTWithNilFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateFilmDetails_notifiesContentUnavailableCOnfigurationToUpdate() {
        let film = Film.sample
        let mockImageLoader = MockImageLoader()
        let filmDetailViewModel = FilmDetailViewModel(film: film, imageLoader: mockImageLoader)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        sut.didUpdateFilmDetails()
        sut.view.layoutIfNeeded()
        
        #expect(sut.title == film.title, "Titles should match.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateWithEmptyState_notifiesContentUnavailableConfigurationToUpdate() {
        let sut = makeSUTWithNilFilm()
        
        sut.loadViewIfNeeded()
        sut.didUpdateWithEmptyState()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    //MARK: - Helper method
    private func makeSUTWithNilFilm() -> ExploreDetailVC {
        let mockImageLoader = MockImageLoader()
        let filmDetailViewModel = FilmDetailViewModel(imageLoader: mockImageLoader)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
}
