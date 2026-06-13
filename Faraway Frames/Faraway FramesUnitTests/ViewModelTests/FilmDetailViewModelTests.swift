//
//  FilmDetailViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 05/02/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

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
    
    @Test func filmDetailViewModel_whenFilmIsPassedIn_setsCurrentStateToContent() {
        let film = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmDetailViewModel(film: film, imageLoader: mockImageLoader, context: testPersistenceController.viewContext)
        
        switch sut.currentState {
        case .noFilmSelected:
            Issue.record("Expected state to be `.content`, but it was `.noFilmSelected`.")
        case .content(let displayModel, _):
            #expect(displayModel.title == film.title, "Should match.")
            #expect(displayModel.visualOriginalTitles == "\(film.originalTitle)\n\(film.originalTitleRomanised)", "Should match.")
        }
    }
    
    @Test func filmDetailViewModel_setFilm_whenFilmIsNil_updatesCurrentState() {
        let film: Film? = nil
        let sut = makeSUT()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .noFilmSelected, "Should update the state to `.noFilmSelected` when film is nil.")
    }
    
    @Test("Quick selection of films ignores the results of the cancelled task", .tags(.networkRequest))
    func filmDetailViewModel_setFilm_cancelsPreviousImageDownloadTask() async {
        let filmA = Film.sample[0]
        let filmB = Film.sample[1]
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader, context: testPersistenceController.viewContext)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy

        sut.setFilm(filmA)
        let taskA = sut.imageLoadTask
        await Task.yield()
        #expect(mockImageLoader.loadCount == 1)

        sut.setFilm(filmB)
        #expect(taskA?.isCancelled == true, "TaskA should be cancelled.")
        await Task.yield()
        #expect(mockImageLoader.loadCount == 2)

        mockImageLoader.resume(shouldSucceed: true)
        mockImageLoader.resume(shouldSucceed: true)
        await Task.yield()

        #expect(spy.callCount == 3, "Should be called three times in total; once for filmA's initial content, twice for filmB's initial content and its movie banner.")
    }

    @Test(.tags(.networkRequest))
    func filmDetailViewModel_getMovieBanner_whenFailedToDownloadMovieBannerImage_returnsFallbackImage() async {
        let film = Film.sample[0]
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader, context: testPersistenceController.viewContext)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        
        sut.setFilm(film)
        await Task.yield()
        mockImageLoader.resume(shouldSucceed: false)
        await Task.yield()
        
        if case .content(let displayModel, let image) = sut.currentState {
            #expect(image == SFSymbols.movieClapper, "Should show the film details with `movieclapper` as a fallback image.")
            #expect(sut.currentState == .content(displayModel: displayModel, image: image), "Should have a `FilmDetailDisplayModel` and an image.")
            #expect(spy.callCount == 2, "Should have called `didUpdateFilmDetails()` twice; once for the film object, and again for the image.")
        }
    }
    
    @Test("Verifies that the display model formats the Japanese title and range correctly for VoiceOver")
    func filmDetailViewModel_displayModel_setsCorrectAccessibilityPropertiesForOriginalTitle() {
        let film = Film.sample[0]
        
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: film)
        let attributedLabel = displayModel.spokenJapaneseTitle
        let expectedPrefix = "Original title: "
        #expect(attributedLabel.string == "\(expectedPrefix)\(film.originalTitle)")
        
        var range = NSRange()
        let prefixLength = (expectedPrefix as NSString).length
        let languageAttribute = attributedLabel.attribute(
            .accessibilitySpeechLanguage,
            at: prefixLength,
            effectiveRange: &range
        ) as? String
        
        #expect(languageAttribute == "ja", "The Japanese text range must be explicitly tagged with 'ja'.")
        #expect(range.location == prefixLength, "Should be equal.")
        #expect(range.length == (film.originalTitle as NSString).length, "Should be equal.")
    }
    

    @Test("Verifies direct property pass-through mapping from `Film`")
    func filmDetailViewModel_displayModel_mapsBasicPropertiesDirectly() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.title == "Castle in the Sky")
        #expect(displayModel.producer == "Isao Takahata")
    }
    
    @Test("Verifies localised default headers and composite newline title spacing configurations")
    func filmDetailViewModel_displayModel_formatsCompositeTitlesAndStaticHeaders() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.synopsisTitle == NSLocalizedString("Synopsis", comment: ""))
        #expect(displayModel.visualOriginalTitles == "天空の城ラピュタ\nTenkū no shiro Rapyuta")
    }
    
    @Test("Verifies bullet formatting and clean text assembly for release metadata and duration text labels")
    func filmDetailViewModel_displayModel_formatsReleaseYearAndDurationLabels() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.releaseYearAndDurationText == "1986 • 124 mins")
        #expect(displayModel.releaseYearAndDurationAccessibilityLabel == "Released in 1986, running time 124 minutes.")
    }
    
    @Test("Verifies speech accessibility labels for credits strings")
    func filmDetailViewModel_displayModel_formatsCreditsAccessibilityLabel() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.creditsAccessibilityLabel == "Credits. Directed by Hayao Miyazaki. Produced by Isao Takahata.")
    }
    
    @Test("Verifies color coding ranges and string layout rules for the Rotten Tomatoes attributed score label")
    func filmDetailViewModel_displayModel_formatsRottenTomatoesScoreTextAndColorRanges() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        let scoreAttribute = displayModel.rottenTomatoesScoreText
        
        #expect(scoreAttribute.string == "Rotten Tomatoes 95%", "Should be equal.")
        
        var prefixRange = NSRange()
        let prefixColor = scoreAttribute.attribute(
            .foregroundColor,
            at: 0,
            effectiveRange: &prefixRange
        ) as? UIColor
        
        #expect(prefixColor == UIColor.systemRed, "The 'Rotten Tomatoes' text prefix must be systemRed.")
        #expect(prefixRange.location == 0, "Should be 0.")
        #expect(prefixRange.length == 16, "Should be 16.")
        
        var scoreRange = NSRange()
        let scoreColor = scoreAttribute.attribute(
            .foregroundColor,
            at: 16,
            effectiveRange: &scoreRange
        ) as? UIColor
        
        let expectedScoreLength = ("Rotten Tomatoes 95%" as NSString).length - 16
        #expect(scoreColor == UIColor.secondaryLabel, "The numeric percentage value block must be secondaryLabel.")
        #expect(scoreRange.location == 16, "Should be 16.")
        #expect(scoreRange.length == expectedScoreLength, "Should be equal.")
    }
    
    @Test("Adding a film to upNext should call delegate method")
    func filmDetailViewModel_addFilmToQueue_callsDelegateMethod() async {
        let sut = makeSUT()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let targetFilm = Film.sample[0]
        
        await sut.addFilmToUpNext(film: targetFilm)
        
        #expect(spy.addedToUpNextCallCount == 1, "Should call delegate method when adding a film to upNext.")
    }
    
    //MARK: - Helper method
    private func makeSUT() -> FilmDetailViewModel {
        let mockImageLoader = MockImageLoader()
        let persistenceController = try! PersistenceController.init(inMemory: true)
        return FilmDetailViewModel(imageLoader: mockImageLoader, context: persistenceController.viewContext)
    }
    
    //MARK: - Film Detail View Model Spy
    final class FilmDetailViewModelSpy: FilmDetailViewModelDelegate {
        var callCount = 0
        func didUpdateFilmDetails() {
            callCount += 1
        }
        
        func didUpdateWithEmptyState() {}
    }
}
