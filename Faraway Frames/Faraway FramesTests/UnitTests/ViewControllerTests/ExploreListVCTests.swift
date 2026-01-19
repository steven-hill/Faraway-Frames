//
//  ExploreListVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 18/01/2026.
//

import Testing
import UIKit
@testable import Faraway_Frames

@MainActor
struct ExploreListVCTests {

    @Test func exploreListVC_canInit() {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let vc = ExploreListVC(viewModel: filmsListViewModel)
        _ = UINavigationController(rootViewController: vc)

        vc.loadViewIfNeeded()
        
        #expect((vc.navigationController != nil), "VC should be inside a navigation controller.")
    }
    
    @Test func exploreListVC_initiallyHasNoFilms() {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let vc = ExploreListVC(viewModel: filmsListViewModel)

        vc.loadViewIfNeeded()
        
        #expect(vc.films.isEmpty, "VC's films should be empty initially.")
    }
    
    @Test func exploreListVC_setsViewModelDelegateToSelf() {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let vc = ExploreListVC(viewModel: filmsListViewModel)
        
        vc.loadViewIfNeeded()
        
        #expect(filmsListViewModel.delegate === vc, "View model's delegate should be set to ExploreListVC.")
    }
    
    @Test func exploreListVC_canUpdateFilmsArraySuccessfully() async throws {
        let mockFilmsListService = setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)

        let vc = ExploreListVC(viewModel: filmsListViewModel)
        
        vc.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        
        #expect(vc.films.count == 22, "VC's film should contain 22 films.")
    }
    
    @Test("ExploreListVC presents an alert for all API errors", arguments: [
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func exploreListVC_presentsAlertForAllErrors(expectedError: APIError) async throws {
        var mockService = MockFilmsListService()
        mockService.result = .failure(expectedError)
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: imageLoader)
        let vc = ExploreListVC(viewModel: filmsListViewModel)
        let spy = PresentationSpy()
        vc.alertPresenter = spy
        
        vc.loadViewIfNeeded()
        vc.didFailToLoadFilms(withError: expectedError)
        
        #expect(spy.presentedVC != nil, "Should not be nil.")
        #expect(spy.presentedVC is UIAlertController, "Alert uses a UIAlertController.")
        #expect(spy.isAnimated == true, "Should present the alert with animation.")
        #expect(spy.presentedVC?.title == "Error: \(expectedError)", "Title should state which error occurred.")
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
    
    // MARK: - Presentation Spy
    fileprivate class PresentationSpy: AlertPresenter {
        var presentedVC: UIViewController?
        var isAnimated: Bool?

        func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            self.presentedVC = viewControllerToPresent
            self.isAnimated = flag
            completion?()
        }
    }
}
