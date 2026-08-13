//
//  FilmsListViewModelUnitTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 16/01/2026.
//

import Foundation
import Testing
@testable import Faraway_Frames

@MainActor
struct FilmsListViewModelUnitTests {
    
    @Test("ViewModel `currentState` is `.idle` on init")
    func filmsListViewModel_onInit_currentStateIsIdle() {
        let sut = makeSUTForSuccessCase()
        
        #expect(sut.currentState == .idle, "Should be `.idle`.")
    }
    
    @Test("ViewModel fetches 22 films from successful network request", .tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenNetworkRequestIsSuccessful_gets22Films() async {
        let sut = makeSUTForSuccessCase()
        
        await sut.getAllFilms()
        
        #expect(sut.films.count == 22, "There should be 22 films.")
        #expect(sut.currentState == .content(
            films: sut.films,
            isUsingArchivedData: false), "Should be `.content(films: sut.films, isUsingArchivedData: false)`.")
    }
    
    @Test("ViewModel requests voice over announcement after fetching films", .tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenNetworkRequestIsSuccessful_requestsVoiceOverAnnouncement() async {
        let sut = makeSUTForSuccessCase()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        await sut.getAllFilms()
        
        #expect(delegateSpy.didEmitEventCallCount == 1, "Should make the request once.")
        #expect(delegateSpy.capturedMessage == "Showing all films", "Should be equal.")
    }
    
    @Test("ViewModel makes network call to fetch films", .tags(.networkRequest))
    func filmsListViewModel_getAllFilms_makesANetworkRequest() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        
        await sut.getAllFilms()

        #expect(mockService.fetchWasCalled == true, "The service should be told to fetch films.")
    }
    
    @Test("ViewModel has correct `currentState` during network request, and calls delgate", .tags(.networkRequest))
    func filmsListViewModel_getAllFilms_duringNetworkRequest_currentStateIsLoadingAllFilmsAndDelegateIsCalled() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        mockService.shouldPauseForLoadingStateTest = true
        
        let task = Task {
            await sut.getAllFilms()
        }
        await Task.yield()
        
        #expect(sut.currentState == .loadingAllFilms)
        #expect(delegateSpy.didChangeStateCallCount == 1, "Should call delegate method once.")
        task.cancel()
    }
    
    @Test("ViewModel handles all API errors correctly", .tags(.networkRequest), arguments: [
        APIError.noInternetConnection,
        APIError.networkConnectionLost,
        APIError.networkTimeout,
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError(""),
        APIError.unknown
    ])
    func filmsListViewModel_getAllFilms_handlesAPIError(expectedError: APIError) async {
        let sut = makeSUTForFailureCase(error: expectedError)
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.getAllFilms()
        
        #expect(sut.films.isEmpty, "Films array should be empty on failure.")
        #expect(sut.currentState == .error(expectedError), "Should be `.error(APIError)`.")
        #expect(delegateSpy.didChangeStateCallCount == 2, "Should have called delegate method twice; once for loading, and again for error.")
    }
    
    @Test("Covers `handleFailure()`",.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_handlesNotConnectedToInternetURLError() async {
        let sut = makeSUTForFailureCase(error: URLError(.notConnectedToInternet))
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.noInternetConnection))
    }
    
    @Test("Covers `handleFailure()`",.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_handlesNetworkTimeOutURLError() async {
        let sut = makeSUTForFailureCase(error: URLError(.timedOut))
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.networkTimeout))
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_handlesGenericError() async {
        let sut = makeSUTForFailureCase(error: NSError(domain: "test", code: -1))
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.unknown))
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_downloadsImageForFilm() async {
        let sut = makeSUTForSuccessCase()
        
        await sut.getAllFilms()
        let filmImage = await sut.getImage(for: sut.films[0])
        
        #expect(filmImage != nil, "Film image should not be nil.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenFailsToDownloadFilmImage_returnsNil() async {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = false
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        
        await sut.getAllFilms()
        let filmImage = await sut.getImage(for: sut.films[0])
        
        #expect(filmImage == nil, "Film image should be nil.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenUsingFileManagerData_currentStateIsCorrect() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        mockService.isUsingFileManagerData = true
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .content(films: sut.films, isUsingArchivedData: true), "Should be using archived data.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenNotUsingFileManagerToReturnFilms_currentStateIsCorrect() async {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .content(films: sut.films, isUsingArchivedData: false), "Should be set to false.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filteredFilmsArray_onInit_isEmpty() {
        let sut = makeSUTForSuccessCase()
        
        #expect(sut.filteredFilms == [], "Should be empty at init.")
    }
    
    @Test("ViewModel handles attempted search after network failure by exiting early via guard",
        .tags(.networkRequest, .search),
          arguments: [
        APIError.noInternetConnection,
        APIError.networkConnectionLost,
        APIError.networkTimeout,
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError(""),
        APIError.unknown
    ])
    func filmsListViewModel_filterFilms_whenThereAreNoFilmsToSearchThrough_doesNotUpdateFilteredFilmsArray(expectedError: APIError) async {
        let sut = makeSUTForFailureCase(error: expectedError)
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.getAllFilms()
        #expect(delegateSpy.didChangeStateCallCount == 2, "Should have been called twice; once for loading state, and again for error.")
        sut.filterFilms(by: "query")
        
        #expect(sut.films.isEmpty, "Films array should be empty on failure.")
        #expect(sut.filteredFilms.isEmpty, "Filtered films array should be empty.")
        #expect(delegateSpy.didChangeStateCallCount == 2, "Should not have been called again because function exits early at guard statement.")
    }
    
    @Test("ViewModel handles attempted search with empty search query by exiting early via guard",
          .tags(.search))
    func filmsListViewModel_filterFilms_withEmptyQuery_returnsAllFilmsAndAnEmptyFilteredFilmsArray() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.filterFilms(by: "")
        
        #expect(sut.films.count == 22, "Films array should have all 22 films.")
        #expect(sut.filteredFilms.isEmpty, "Filtered films should be empty.")
        #expect(delegateSpy.didChangeStateCallCount == 0, "Should not have been called because function exits early at guard statement.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_withPartialQueryMatch_returnsFilmsWithPartialMatches() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.filterFilms(by: "Cas")
        
        #expect(sut.filteredFilms.count == 2, "Should have two films that have `cas` in the title.")
        #expect(delegateSpy.didChangeStateCallCount == 1, "Should have called delegate method once.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_isNotCaseSensitive() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()

        sut.filterFilms(by: "cas")
        
        #expect(sut.filteredFilms.count == 2, "Should have two films that have `cas` in the title.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_whenThereAreNoMatches_returnsEmptyArray() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy

        sut.filterFilms(by: "No matching titles")
        
        #expect(sut.filteredFilms.isEmpty, "No matches should return an empty array.")
        #expect(sut.currentState == .emptySearchResults, "Should be `.emptySearchResults` state.")
        #expect(delegateSpy.didChangeStateCallCount == 1, "Should have called delegate method once.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_removesLeadingAndTrailingWhiteSpaces() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: " Castle ")
        
        #expect(sut.filteredFilms.count == 2, "Should be two films.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_removesMultipleSpacesInBetweenWords() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle  in the sky")
        
        #expect(sut.filteredFilms.count == 1, "Should be one film.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_removesPunctuation() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle, in the sky.!")
        
        #expect(sut.filteredFilms[0].title == "Castle in the Sky", "Should be `Castle in the Sky`.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_handlesEmoji() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "😎")
        
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_handlesTextAndEmoji() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle in the Sky😎")
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
        
        sut.filterFilms(by: "😎Castle in the Sky")
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_whenThereAreSearchResults_requestsVoiceOverAnnouncement() async {
        let sut = makeSUTForSuccessCase()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        await sut.getAllFilms()

        sut.filterFilms(by: "Cas")
        
        #expect(delegateSpy.didEmitEventCallCount == 2, "Should be called twice; once for loading all films, and again for filtering.")
        #expect(delegateSpy.capturedMessage == "2 found", "Should be equal.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filterFilms_whenSearchResultsAreEmpty_requestsVoiceOverAnnouncement() async {
        let sut = makeSUTForSuccessCase()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        await sut.getAllFilms()

        sut.filterFilms(by: "No results")
        
        #expect(delegateSpy.didEmitEventCallCount == 2, "Should be called twice; once for loading all films, and again for filtering.")
        #expect(delegateSpy.capturedMessage == "No results found. Try another query.", "Should be equal.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_resetAllFilms_resetsFilmsArrayToAllFilms() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.resetAllFilms()
        
        #expect(sut.films.count == 22, "Should have 22 films.")
        #expect(sut.currentState == .content(films: sut.films, isUsingArchivedData: false), "Should be `.content(films: sut.films, isUsingArchivedData: false)`.")
    }
    
    @Test func filmsListViewModel_resetAllFilms_emptiesFilteredFilms() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        sut.filterFilms(by: "Cas")
        #expect(!sut.filteredFilms.isEmpty, "Should have some films.")
        
        sut.resetAllFilms()
        
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test func filmsListViewModel_resetAllFilms_requestsVoiceOverAnnouncement() async {
        let sut = makeSUTForSuccessCase()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        await sut.getAllFilms()
        sut.filterFilms(by: "Cas")
        
        sut.resetAllFilms()
        
        #expect(delegateSpy.didEmitEventCallCount == 3, "Should be called three times; once for loading all films, twice for filtering, and again for resetting.")
        #expect(delegateSpy.capturedMessage == "Showing all films", "Should be equal.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_retryLoadingAllFilms_makesAnotherNetworkCall() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.retryLoadingAllFilms()
        
        #expect(sut.refreshTask != nil, "A new task should be created")
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
        #expect(sut.currentState == .loadingAllFilms, "State should change to `.loadingAllFilms`")
        #expect(delegateSpy.didChangeStateCallCount == 1, "Should have called delegate method once.")
        
        await sut.refreshTask?.value
        #expect(mockService.fetchWasCalled == true)
    }
    
    @Test("Back-to-back network retries cancel the previous task")
    func filmsListViewModel_retryLoadingAllFilms_cancelsPreviousTask() async throws {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
        
        sut.retryLoadingAllFilms()
        let firstTask = try #require(sut.refreshTask, "Should have created first task.")
        
        sut.retryLoadingAllFilms()
        let secondTask = try #require(sut.refreshTask, "Should have created second task.")
        
        #expect(firstTask.isCancelled, "Should have cancelled the first task when a new retry starts.")
        #expect(!secondTask.isCancelled, "The second task should actively run.")
        _ = await secondTask.result
    }
    
    @Test("if a film exists in both `films` and `filteredFilms` arrays, `updateFilmInArrays` updates a film's properties in both arrays, updates state, and calls delegate correct number of times.")
    func filmsListViewModel_updateFilmInArrays_whenFilmExistsInBothArrays_updatesBothAndSetsStateAndCallsDelegateCorrectNumberOfTimes() async {
        let sut = makeSUTForSuccessCase()
        let delegateSpy = FilmsListViewModelDelegateSpy()
        sut.delegate = delegateSpy
        await sut.getAllFilms()
        sut.filterFilms(by: "Cas")
        var updatedFilm = sut.films[0]
        updatedFilm.isUpNext = true
        updatedFilm.isWatched = true
        #expect(delegateSpy.didChangeStateCallCount == 3, "Should have been called three times: once for loading state, twice for content, and again for filtering.")
        
        sut.updateFilmInArrays(updatedFilm)
        
        #expect(sut.films[0].isUpNext == true, "Should have updated to true.")
        #expect(sut.films[0].isWatched == true, "Should have updated to true.")
        #expect(sut.filteredFilms[0].isUpNext == true, "Should have updated to true.")
        #expect(sut.filteredFilms[0].isWatched == true, "Should have updated to true.")
        #expect(sut.currentState == .content(films: sut.filteredFilms, isUsingArchivedData: false), "Should be `.content(isUsingArchivedData: false)`.")
        #expect(delegateSpy.didChangeStateCallCount == 5, "Should be five in total; the fourth time for `films`, and the fifth time for `filteredFilms`.")
    }
    
    @Test("`updateFilmInArrays` gracefully does nothing if the film ID does not exist in the arrays")
       func filmsListViewModel_updateFilmInArrays_whenFilmDoesNotExist_leavesArraysUnchanged() async {
           let sut = makeSUTForSuccessCase()
           let delegateSpy = FilmsListViewModelDelegateSpy()
           sut.delegate = delegateSpy
           await sut.getAllFilms()
           sut.filterFilms(by: "Cas")
           let updatedFilm = Film(id: "non-existent-ID", title: "", originalTitle: "", originalTitleRomanised: "", image: "", movieBanner: "", description: "", director: "", producer: "", releaseDate: "", runningTime: "", rottenTomatoesScore: "", url: "")
           
           #expect(delegateSpy.didChangeStateCallCount == 3, "Should have been called three times: once for loading state, twice for content, and again for filtering.")
           
           sut.updateFilmInArrays(updatedFilm)
           
           #expect(sut.films[0].isUpNext == false, "Should be false and therefore unchanged.")
           #expect(sut.films[0].isWatched == false, "Should be false and therefore unchanged.")
           #expect(sut.filteredFilms[0].isUpNext == false, "Should be false and therefore unchanged.")
           #expect(sut.filteredFilms[0].isWatched == false, "Should be false and therefore unchanged.")
           #expect(delegateSpy.didChangeStateCallCount == 3, "Should still be three; delegate method should not have been called any more times because film ID did not exist in the arrays.")
       }
    
    // MARK: - SUT Helper Methods
    private func makeSUTForSuccessCase() -> FilmsListViewModel {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        return FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
    }
    
    private func makeSUTForFailureCase(error: Error) -> FilmsListViewModel {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForFailureCase(error: error)
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        return FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader, filmSyncService: filmSyncService)
    }
    
    // MARK: - Films List View Model Delegate
    final class FilmsListViewModelDelegateSpy: FilmsListViewModelDelegate {
        var didChangeStateCallCount = 0
        var didEmitEventCallCount = 0
        var capturedMessage: String?
        
        func viewModel(
            _ viewModel: FilmsListViewModel,
            didChange
            state: FilmsListViewModel.FilmsListState
        ) {
            didChangeStateCallCount += 1
        }
        
        func viewModel(
            _ viewModel: FilmsListViewModel,
            didEmit
            event: FilmsListViewModel.FilmsListEvent
        ) {
            guard case let .voiceOverAnnouncement(message) = event else { return }
            capturedMessage = message
            didEmitEventCallCount += 1
        }
    }
}
