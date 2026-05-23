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
        let sut = FilmDetailViewModel(film: film, imageLoader: mockImageLoader)
        
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
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader)
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

    @Test(.tags(.networkRequest)) func filmDetailViewModel_getMovieBanner_whenFailedToDownloadMovieBannerImage_returnsFallbackImage() async {
        let film = Film.sample[0]
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader)
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
    
    //MARK: - Helper method
    private func makeSUT() -> FilmDetailViewModel {
        let mockImageLoader = MockImageLoader()
        return FilmDetailViewModel(imageLoader: mockImageLoader)
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


