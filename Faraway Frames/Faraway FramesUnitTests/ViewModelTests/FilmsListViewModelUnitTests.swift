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
    
    @Test func filmsListViewModel_onInit_currentStateIsIdle() {
        let sut = makeSUTForSuccessCase()
        
        #expect(sut.currentState == .idle, "Should be `.idle`.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_whenNetworkRequestIsSuccessful_gets22Films() async {
        let sut = makeSUTForSuccessCase()
        
        await sut.getAllFilms()
        
        #expect(sut.films.count == 22, "There should be 22 films.")
        #expect(sut.currentState == .content(isUsingArchivedData: false), "Should be `.content(isUsingArchivedData: false)`.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_makesANetworkRequest() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.getAllFilms()

        #expect(mockService.fetchWasCalled == true, "The service should be told to fetch films.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_duringNetworkRequest_currentStateIsLoadingAllFilms() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        mockService.shouldPauseForLoadingStateTest = true
        
        let task = Task {
            await sut.getAllFilms()
        }
        await Task.yield()
        
        #expect(sut.currentState == .loadingAllFilms)
        task.cancel()
    }
    
    @Test("ViewModel handles all API errors correctly", .tags(.networkRequest), arguments: [
        APIError.noInternetConnection,
        APIError.networkConnectionLost,
        APIError.networkTimeout,
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func filmsListViewModel_handlesAPIError(expectedError: APIError) async {
        let sut = makeSUTForFailureCase(error: expectedError)
        
        await sut.getAllFilms()
        
        #expect(sut.films.isEmpty, "Films array should be empty on failure.")
        #expect(sut.currentState == .error(expectedError), "Should be `.error(APIError)`.")
    }
    
    @Test("Covers `handleFailure()`",.tags(.networkRequest))
    func filmsListViewModel_handlesNotConnectedToInternetURLError() async {
        let sut = makeSUTForFailureCase(error: URLError(.notConnectedToInternet))
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.noInternetConnection))
    }
    
    @Test("Covers `handleFailure()`",.tags(.networkRequest))
    func filmsListViewModel_handlesNetworkTimeOutURLError() async {
        let sut = makeSUTForFailureCase(error: URLError(.timedOut))
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.networkTimeout))
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_handlesGenericError() async {
        let sut = makeSUTForFailureCase(error: NSError(domain: "test", code: -1))
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.unknown))
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_downloadsImageForFilm() async {
        let sut = makeSUTForSuccessCase()
        
        await sut.getAllFilms()
        let filmImage = await sut.getImage(for: sut.films[0])
        
        #expect(filmImage != nil, "Film image should not be nil.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_whenFailsToDownloadFilmImage_returnsNil() async {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = false
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.getAllFilms()
        let filmImage = await sut.getImage(for: sut.films[0])
        
        #expect(filmImage == nil, "Film image should be nil.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenUsingFileManagerData_currentStateIsCorrect() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        mockService.isUsingFileManagerData = true
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .content(isUsingArchivedData: true), "Should be set to true.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_getAllFilms_whenNotUsingFileManagerToReturnFilms_currentStateIsCorrect() async {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .content(isUsingArchivedData: false), "Should be set to false.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filteredFilmsArray_onInit_isEmpty() {
        let sut = makeSUTForSuccessCase()
        
        #expect(sut.filteredFilms == [], "Should be empty at init.")
    }
    
    @Test("ViewModel handles attempted search after network failure", .tags(.search), arguments: [
        APIError.noInternetConnection,
        APIError.networkConnectionLost,
        APIError.networkTimeout,
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func filmsListViewModel_filter_whenThereAreNoFilmsToSearchThrough_doesNotUpdateFilteredFilmsArray(expectedError: APIError) async {
        let sut = makeSUTForFailureCase(error: expectedError)
        
        await sut.getAllFilms()
        sut.filterFilms(by: "query")
        
        #expect(sut.films.isEmpty, "Films array should be empty on failure.")
        #expect(sut.filteredFilms.isEmpty, "Filtered films array should be empty.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_withEmptyQuery_returnsAllFilmsAndAnEmptyFilteredFilmsArray() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
 
        sut.filterFilms(by: "")
        
        #expect(sut.films.count == 22, "Films array should have all 22 films.")
        #expect(sut.filteredFilms.isEmpty, "Filtered films should be empty.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_withPartialQueryMatch_returnsFilmsWithPartialMatches() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()

        sut.filterFilms(by: "Cas")
        
        #expect(sut.filteredFilms.isEmpty == false, "Filtered films should not be empty.")
        #expect(sut.filteredFilms.count == 2, "Should have two films that have `cas` in the title.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_isNotCaseSensitive() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()

        sut.filterFilms(by: "cas")
        
        #expect(sut.filteredFilms.isEmpty == false, "Filtered films should not be empty.")
        #expect(sut.filteredFilms.count == 2, "Should have two films that have `cas` in the title.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_whenThereAreNoMatches_returnsEmptyArray() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()

        sut.filterFilms(by: "No matching titles")
        
        #expect(sut.filteredFilms.isEmpty, "No matches should return an empty array.")
        #expect(sut.currentState == .emptySearchResults, "Should be `.emptySearchResults` state.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_removesLeadingAndTrailingWhiteSpaces() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: " Castle ")
        
        #expect(sut.filteredFilms.count == 2, "Should be two films.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_removesMultipleSpacesInBetweenWords() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle  in the sky")
        
        #expect(sut.filteredFilms.count == 1, "Should be one film.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_removesPunctuation() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle, in the sky.!")
        
        #expect(sut.filteredFilms[0].title == "Castle in the Sky", "Should be `Castle in the Sky`.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_handlesEmoji() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "😎")
        
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test(.tags(.search))
    func filmsListViewModel_filter_handlesTextAndEmoji() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle in the Sky😎")
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
        
        sut.filterFilms(by: "😎Castle in the Sky")
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_resetAllFilms_resetsFilmsArrayToAllFilms() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        
        sut.resetAllFilms()
        
        #expect(sut.films.count == 22, "Should have 22 films.")
        #expect(sut.currentState == .content(isUsingArchivedData: false), "Should be `.content(isUsingArchivedData: false)`.")
    }
    
    @Test func filmsListViewModel_resetAllFilms_emptiesFilteredFilms() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()
        sut.filterFilms(by: "Cas")
        #expect(!sut.filteredFilms.isEmpty, "Should have some films.")
        
        sut.resetAllFilms()
        
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListViewModel_retryLoadingAllFilms_makesAnotherNetworkCall() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        sut.retryLoadingAllFilms()
        await sut.refreshTask?.value
        
        #expect(mockService.fetchWasCalled == true)
    }
    
    @Test func filmsListViewModel_retryLoadingAllFilms_emptiesFilteredFilms() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        sut.retryLoadingAllFilms()
        
        #expect(sut.filteredFilms.isEmpty, "Should be empty.")
    }
    
    @Test func filmsListViewModel_whenVoiceOverIsOnAndThereAreSearchResults_voiceOverAnnouncesTheNumberOfResults() async {
        let sut = makeSUTForSuccessCase()
        await sut.getAllFilms()

        sut.filterFilms(by: "Cas")
        
        #expect(delegateSpy.didRequestVoiceOverAnnouncement)
        #expect(delegateSpy.capturedMessage, "1 found")
    }
    
    // MARK: - SUT Helper Methods
    private func makeSUTForSuccessCase() -> FilmsListViewModel {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        return FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
    }
    
    private func makeSUTForFailureCase(error: Error) -> FilmsListViewModel {
        let mockService = MockFilmsListServiceHelper.setupMockServiceForFailureCase(error: error)
        let mockImageLoader = MockImageLoader()
        return FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
    }
}
