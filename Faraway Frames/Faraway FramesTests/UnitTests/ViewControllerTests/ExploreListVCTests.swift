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
        let sut = makeSUT()
        _ = UINavigationController(rootViewController: sut)

        sut.loadViewIfNeeded()
        
        #expect((sut.navigationController != nil), "VC should be inside a navigation controller.")
    }
    
    @Test func exploreListVC_initiallyHasNoFilms() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.films.isEmpty, "VC's films should be empty initially.")
    }
    
    @Test func exploreListVC_setsViewModelDelegateToSelf() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.viewModel.delegate != nil, "View model's delegate should be set.")
    }
    
    @Test func exploreListVC_setsCollectionViewDelegate() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.collectionView.delegate != nil, "Collection view delegate should be set.")
    }
    
    @Test func exploreListVC_setsCollectionViewDataSource() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.collectionView.dataSource != nil, "Collection view data source should be set.")
    }
    
    @Test func exploreListVC_columnCount_returnsCorrectNumberOfColumns() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
                
        #expect(sut.columnCount(for: 801) == 3, "Should be 3.")
        #expect(sut.columnCount(for: 800) == 1, "Should be 1.")
    }
    
    @Test func exploreListVC_canUpdateFilmsArraySuccessfully() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        
        #expect(sut.films.count == 22, "VC's film should contain 22 films.")
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
        #expect(spy.presentedVC is UIAlertController, "Alert should use a UIAlertController.")
        #expect(spy.isAnimated == true, "Should present the alert with animation.")
        #expect(spy.presentedVC?.title == "Error: \(expectedError)", "Title should state which error occurred.")
    }
    
    @Test func exploreListVC_didUpdateFilms_updatesCollectionViewItemCount() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let films: [Film] = [.sample]
        
        sut.didUpdateFilms(films)
        
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        #expect(itemCount == 1, "Should be 1 item in the collection view.")
    }
    
    @Test func exploreListVC_dataSource_returnsACell() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let films: [Film] = [.sample]
        
        sut.didUpdateFilms(films)
        
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath)
        #expect(cell != nil, "Should not be nil.")
    }
    
    // MARK: - Helper method
    fileprivate func makeSUT() -> ExploreListVC {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        return ExploreListVC(viewModel: filmsListViewModel)
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
