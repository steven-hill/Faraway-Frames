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
    
    @Test func exploreDetailVC_whenFilmIsNil_localStatePropertiesAreFalse() {
        let sut = makeSUTWhenFilmIsNil()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.isUpNext == false, "Should be false.")
        #expect(sut.isWatched == false, "Should be false.")
    }
    
    @Test func exploreDetailVC_withFilm_localStatePropertiesAreInitiallyFalse() {
        let sut = makeSUTWithFilm()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.isUpNext == false, "Should be false.")
        #expect(sut.isWatched == false, "Should be false.")
    }
    
    @Test func exploreDetailVC_whenFilmIsNil_isInsideANavigationController() {
        let sut = makeSUTWhenFilmIsNil()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_withFilm_isInsideANavigationController() {
        let sut = makeSUTWithFilm()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_whenFilmIsNil_canLoadView() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func exploreDetailVC_withFilm_canLoadView() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_setsDelegate() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.filmDetailViewModel.delegate != nil, "Should set the delegate.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_withFilm_setsDelegate() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.filmDetailViewModel.delegate != nil, "Should set the delegate.")
    }

    @Test func exploreDetailVC_viewDidLoad_withFilm_contentUnavailableConfiguration_isNil() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_contentUnavailableConfiguration_isNil() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_displaysEmptyState() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_navigationBarTitle_isNil() {
        let sut = makeSUTWhenFilmIsNil()

        sut.loadViewIfNeeded()
    
        #expect(sut.title == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_withFilm_navigationBarTitle_isNil() {
        let sut = makeSUTWithFilm()

        sut.loadViewIfNeeded()
    
        #expect(sut.title == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateFilmDetails_notifiesContentUnavailableConfigurationToUpdate() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.didUpdateFilmDetails()
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateWithEmptyState_notifiesContentUnavailableConfigurationToUpdate() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.didUpdateWithEmptyState()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test("`didUpdateUpNextStatus` flips VC's state property")
    func exploreDetailVC_didUpdateUpNextStatus_flipsStateProperty() {
        let sut = makeSUTWithFilm()
        
        sut.didUpdateUpNextStatus(isUpNext: true)
        
        #expect(sut.isUpNext == true, "Should be true.")
    }
    
    @Test("Integration test to check that the label successfully receives the text from ViewModel.")
    func exploreDetailVC_createContent_successfullyBindsAccessibilityPropertiesToLabel() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        let targetIdentifier = "ExploreDetailVC_OriginalTitlesLabel"
        let foundLabel = sut.view.findView(withIdentifier: targetIdentifier) as? UILabel        
        guard let label = foundLabel else {
            Issue.record("Could not find a UILabel with accessibilityIdentifier: '\(targetIdentifier)'.")
            return
        }
        
        let expectedPrefix = "Original title: "
        #expect(label.accessibilityAttributedLabel?.string == "\(expectedPrefix)\(Film.sample[0].originalTitle)")
    }
    
    @Test func exploreDetailVC_whenFilmIsNil_buttonsContainerIsHidden() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        
        #expect(sut.view.findView(withIdentifier: "ExploreDetailVC_ButtonsContainer")?.isHidden == true,
                "Buttons container must be hidden when state is `.noFilmSelected`.")
    }
    
    @Test func exploreDetailVC_withFilm_buttonsContainerIsVisible() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        
        #expect(sut.view.findView(withIdentifier: "ExploreDetailVC_ButtonsContainer")?.isHidden == false,
                "Buttons container must be visible when state is `.content`.")
    }
    
    //MARK: - Helper Methods
    private func makeSUTWhenFilmIsNil() -> ExploreDetailVC {
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmDetailViewModel = FilmDetailViewModel(imageLoader: mockImageLoader, filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
    
    private func makeSUTWithFilm() -> ExploreDetailVC {
        let film = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmDetailViewModel = FilmDetailViewModel(film: film, imageLoader: mockImageLoader, filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
}

//MARK: - Extension on UIView
private extension UIView {
    func findView(withIdentifier identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier {
            return self
        }
        for subview in subviews {
            if let foundView = subview.findView(withIdentifier: identifier) {
                return foundView
            }
        }
        return nil
    }
}
