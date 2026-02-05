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
        let filmDetailViewModel = FilmDetailViewModel(film: .sample)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_canInit_whenFilmIsNil() {
        let filmDetailViewModel = FilmDetailViewModel()
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_setsDelegate() {
        let filmDetailViewModel = FilmDetailViewModel(film: .sample)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.filmDetailViewModel.delegate != nil, "Should set the delegate.")
    }

    @Test func exploreDetailVC_viewDidLoad_displaysFilmWhenFilmIsProvided() {
        let film = Film.sample
        let filmDetailViewModel = FilmDetailViewModel(film: film)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.title == film.title, "Titles should match.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_displaysEmptyStateWhenFilmIsNil() {
        let filmDetailViewModel = FilmDetailViewModel()
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateFilmDetails_notifiesContentUnavailableCOnfigurationToUpdate() {
        let film = Film.sample
        let filmDetailViewModel = FilmDetailViewModel(film: film)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        sut.didUpdateFilmDetails()
        sut.view.layoutIfNeeded()
        
        #expect(sut.title == film.title, "Titles should match.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateWithEmptyState_notifiesContentUnavailableCOnfigurationToUpdate() {
        let filmDetailViewModel = FilmDetailViewModel()
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        
        sut.loadViewIfNeeded()
        sut.didUpdateWithEmptyState()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
}
