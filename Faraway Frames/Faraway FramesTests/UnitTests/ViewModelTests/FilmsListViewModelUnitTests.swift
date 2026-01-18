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
    
    @Test func filmsListViewModel_gets22FilmsInSuccessCase() async throws {
        let mockService = setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        try! await viewModel.getAllFilms()
        
        #expect(viewModel.films.count == 22, "There should be 22 films.")
        #expect(viewModel.viewModelError == nil, "Error should be nil.")
    }
    
    @Test("ViewModel handles all API errors correctly", arguments: [
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func filmsListViewModel_handlesErrors(expectedError: APIError) async {
        var mockService = MockFilmsListService()
        mockService.result = .failure(expectedError)
        let mockImageLoader = MockImageLoader()
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        try! await viewModel.getAllFilms()
        
        #expect(viewModel.films.isEmpty, "Films array should be empty on failure.")
        #expect(viewModel.viewModelError == expectedError, "Error property should match the API error.")
    }
    
    @Test func filmsListViewModel_downloadsImageForFilm() async throws {
        let mockService = setupMockServiceForSuccessCase()
        let mockImageLoader = MockImageLoader()
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        try! await viewModel.getAllFilms()
        let filmImage = await viewModel.getImage(for: viewModel.films[0])
        
        #expect(filmImage != nil, "Film image should not be nil.")
    }
    
    @Test func filmsListViewModel_returnNilWhenFailedToDownLoadFilmImage() async throws {
        let mockService = setupMockServiceForSuccessCase()
        var mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = false
        let viewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: mockImageLoader)
        
        try! await viewModel.getAllFilms()
        let filmImage = await viewModel.getImage(for: viewModel.films[0])
        
        #expect(filmImage == nil, "Film image should be nil.")
    }
    
    // MARK: - Helper method
    private func setupMockServiceForSuccessCase() -> MockFilmsListService {
        var mockService = MockFilmsListService()
        let films = try! loadAndDecodeFilmsFromJSON()
        mockService.result = .success(films)
        return mockService
    }
    
    private func loadAndDecodeFilmsFromJSON() throws -> [Film] {
        guard let bundle = Bundle(identifier: "com.StevenHill.Faraway-FramesTests"),
              let url = bundle.url(forResource: "ghibliFilms", withExtension: "json") else {
            Issue.record("ghibliFilms JSON file not found")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Film].self, from: data)
        } catch {
            Issue.record("ghibliFilms JSON file decoding failed with error: \(error)")
            return []
        }
    }
}
