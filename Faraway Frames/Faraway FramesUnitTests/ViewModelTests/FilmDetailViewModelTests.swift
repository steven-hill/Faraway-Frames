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
        
        sut.updateUI()
        
        #expect(sut.currentState == .content(film), "Should be `.content` when film is provided.")
    }
    
    @Test func filmDetailViewModel_setFilm_whenThereIsAFilm_updatesCurrentState() {
        let film = Film.sample[0]
        let sut = makeSUT()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .content(film), "Should update the state to `.content` when a film is set.")
    }
    
    @Test func filmDetailViewModel_setFilm_whenFilmIsNil_updatesCurrentState() {
        let film: Film? = nil
        let sut = makeSUT()
        
        sut.setFilm(film)
        
        #expect(sut.currentState == .noFilmSelected, "Should update the state to `.noFilmSelected` when a film is nil.")
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
        await Task.yield()
        #expect(mockImageLoader.loadCount == 1)

        sut.setFilm(filmB)
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
        
        if case .content(_, let image) = sut.currentState {
            #expect(image == UIImage(systemName: "movieclapper"), "Should show the film details with `movieclapper` as a fallback image.")
            #expect(sut.currentState == .content(film, image: image), "Should have a `Film` and an image.")
            #expect(spy.callCount == 2, "Should have called `didUpdateFilmDetails()` twice; once for the film object, and again for the image.")
        }
    }
    
    @Test(.tags(.networkRequest)) func filmDetailViewModel_cancelImageLoad_marksTaskForCancellationAndSetsItToNil() {
        let sut = makeSUT()
        sut.setFilm(Film.sample[0])
        let capturedTask = sut.imageLoadTask
        
        sut.cancelImageLoad()
        
        #expect(capturedTask?.isCancelled == true, "Should be marked for cancellation.")
        #expect(sut.imageLoadTask == nil, "Should be nil.")
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


