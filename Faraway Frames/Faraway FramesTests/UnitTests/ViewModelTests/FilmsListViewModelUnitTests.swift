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
    
    @Test func filmsListViewModel_currentStateIsLoadingAllFilms_OnInit() {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        #expect(sut.currentState == .loadingAllFilms, "Should be `.loadingAllFilms`.")
    }
    
    @Test func filmsListViewModel_gets22FilmsInSuccessCase() async throws {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await viewModel.getAllFilms()
        
        #expect(viewModel.films.count == 22, "There should be 22 films.")
        #expect(viewModel.filmsListError == nil, "Error should be nil.")
        #expect(viewModel.currentState == .content, "Should be `.content`.")
    }
    
    @Test func filmsListViewModel_getAllFilms_makesANetworkRequest() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.getAllFilms()

        #expect(mockService.fetchWasCalled == true, "The service should be told to fetch films.")
    }
    
    @Test func filmsListViewModel_getAllFilms_duringNetworkRequestStateIsLoadingAllFilms() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)

        let task = Task {
            await sut.getAllFilms()
        }

        #expect(sut.currentState == .loadingAllFilms)
        await task.value
    }
    
    @Test("ViewModel handles all API errors correctly", arguments: [
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func filmsListViewModel_handlesErrors(expectedError: APIError) async {
        let mockService = MockFilmsListService()
        mockService.result = .failure(expectedError)
        let mockImageLoader = MockImageLoader()
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await viewModel.getAllFilms()
        
        #expect(viewModel.films.isEmpty, "Films array should be empty on failure.")
        #expect(viewModel.filmsListError == expectedError, "Error property should match the API error.")
        #expect(viewModel.currentState == .error(expectedError), "Should be `.error(APIError)`.")
    }
    
    @Test func filmsListViewModel_handlesGenericError() async {
        let mockService = MockFilmsListService()
        mockService.result = .failure(NSError(domain: "test", code: -1))
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.getAllFilms()
        
        #expect(sut.currentState == .error(.unknown))
    }
    
    @Test func filmsListViewModel_downloadsImageForFilm() async throws {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await viewModel.getAllFilms()
        let filmImage = await viewModel.getImage(for: viewModel.films[0])
        
        #expect(filmImage != nil, "Film image should not be nil.")
    }
    
    @Test func filmsListViewModel_returnNilWhenFailedToDownloadFilmImage() async throws {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        var mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = false
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await viewModel.getAllFilms()
        let filmImage = await viewModel.getImage(for: viewModel.films[0])
        
        #expect(filmImage == nil, "Film image should be nil.")
    }
    
    @Test func filmsListViewModel_filteredFilmsArray_isEmptyOnInit() {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        #expect(sut.filteredFilms == [], "Should be empty at init.")
    }
    
    @Test func filmsListViewModel_filter_doesNotUpdateFilteredFilmsArray_whenThereAreNoFilmsToSearchThrough() async {
        let expectedError = APIError.unknown
        let mockService = MockFilmsListService()
        mockService.result = .failure(expectedError)
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.getAllFilms()
        sut.filterFilms(by: "query")
        
        #expect(sut.films.isEmpty, "Films array should be empty on failure.")
        #expect(sut.filteredFilms.isEmpty, "Filtered films array should be empty.")
    }
    
    @Test func filmsListViewModel_filter_withEmptyQuery_returnsAllFilmsAndAnEmptyFilteredFilmsArray() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()
 
        sut.filterFilms(by: "")
        
        #expect(sut.films.count == 22, "Films array should have all 22 films.")
        #expect(sut.filteredFilms.isEmpty, "Filtered films should be empty.")
    }
    
    @Test func filmsListViewModel_filter_withPartialQueryMatch_returnsFilmsWithPartialMatches() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()

        sut.filterFilms(by: "Cas")
        
        #expect(sut.filteredFilms.isEmpty == false, "Filtered films should not be empty.")
        #expect(sut.filteredFilms.count == 2, "Should have two films that have `cas` in the title.")
    }
    
    @Test func filmsListViewModel_filter_isNotCaseSensitive() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()

        sut.filterFilms(by: "cas")
        
        #expect(sut.filteredFilms.isEmpty == false, "Filtered films should not be empty.")
        #expect(sut.filteredFilms.count == 2, "Should have two films that have `cas` in the title.")
    }
    
    @Test func filmsListViewModel_filter_returnsEmptyArray_whenThereAreNoMatches() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()

        sut.filterFilms(by: "No matching titles")
        
        #expect(sut.filteredFilms.isEmpty, "No matches should return an empty array.")
        #expect(sut.currentState == .emptySearchResults, "Should be `.emptySearchResults` state.")
    }
    
    @Test func filmsListViewModel_filter_removesLeadingAndTrailingWhiteSpaces() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()
        
        sut.filterFilms(by: " Castle ")
        
        #expect(sut.filteredFilms.count == 2, "Should be two films.")
    }
    
    @Test func filmsListViewModel_filter_removesMultipleSpacesInBetweenWords() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle  in the sky")
        
        #expect(sut.filteredFilms.count == 1, "Should be one film.")
    }
    
    @Test func filmsListViewModel_filter_removesPunctuation() async {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()
        
        sut.filterFilms(by: "Castle, in the sky.!")
        
        #expect(sut.filteredFilms[0].title == "Castle in the Sky", "Should be `Castle in the Sky`.")
    }
    
    @Test func filmsListViewModel_resetAllFilms_resetsFilmsArrayToAllFilms() async throws {
        let mockService = MockServiceHelper.setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        await sut.getAllFilms()
        
        sut.resetAllFilms()
        
        #expect(sut.films.count == 22, "Should have 22 films.")
        #expect(sut.currentState == .content, "Should be `.content`.")
    }
    
    @Test func filmsListViewModel_retryLoadingAllFilms_makesAnotherNetworkCall() async {
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let sut = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        await sut.retryLoadingAllFilms()
        
        #expect(mockService.fetchWasCalled == true)
    }
}
