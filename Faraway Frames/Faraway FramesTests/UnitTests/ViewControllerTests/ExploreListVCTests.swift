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
        let sut = createSUTForDataSource()
        
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 1, "Should be 1 item in the collection view.")
    }
    
    @Test func exploreListVC_dataSource_returnsACell() {
        let sut = createSUTForDataSource()
        
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath)
        
        #expect(cell != nil, "Should not be nil.")
    }
    
    @Test func exploreListVC_filmsLookup_populatesCorrectly() {
        let sut = createSUTForDataSource()
        
        #expect(sut.filmLookup.count == 1, "Dictionary should have 1 film.")
    }
    
    @Test func exploreListVC_filmsLookup_returnsCorrectFilm() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let films: [Film] = [.sample]
        
        sut.didUpdateFilms(films)
        
        #expect(sut.filmLookup["2baf70d1-42bb-4437-b551-e5fed5a87abe"] != nil, "Should not be nil.")
        #expect(sut.filmLookup["2baf70d1-42bb-4437-b551-e5fed5a87abe"] == films.first, "ID should be for 'Castle in the Sky'.")
        #expect(sut.filmLookup.first?.value.title == "Castle in the Sky", "Title should be 'Castle in the Sky'.")
    }
    
    @Test func exploreListVC_filmsLookup_returnsNilForUnknownID() {
        let sut = createSUTForDataSource()
        
        #expect(sut.filmLookup["non existent ID"] == nil, "Should return nil if no film with that ID exists.")
    }
    
    @Test func exploreListVC_createSpinnerView_callsDidMove() {
        let sut = makeSUT()
        let spy = SpinnerSpy()
        sut.child = spy
        
        sut.createSpinnerView()
        
        #expect(spy.didMoveToParentWasCalled == true, "didMove(toParent:) should be called by the container.")
        #expect(spy.capturedParentVC == sut, "The parent view controller should be the one that was passed in.")
    }
    
    @Test func exploreListVC_removeSpinnerView_removesSpinner() {
        let sut = makeSUT()
        
        sut.removeSpinnerView()
        
        #expect(!sut.children.contains(sut.child), "Spinner is no longer a child of ExploreListVC.")
    }
    
    @Test func exploreListVC_removeSpinnerView_callsWillMove() {
        let sut = makeSUT()
        let spy = SpinnerSpy()
        sut.child = spy
        
        sut.removeSpinnerView()
        
        #expect(spy.willMoveToParentWasCalled == true, "didMove(toParent:) should be called by the container.")
        #expect(spy.capturedParentVC == nil, "Nil was passed in.")
    }
    
    @Test func exploreListVC_updateCellImage_setsImageWhenCellHasNotBeenReused() async {
        let (sut, cell, indexPath) = makeSUTForUpdateCellImageTests()
        
        await sut.updateCellImage(cell, film: .sample, indexPath: indexPath)
        
        let updatedConfig = cell.contentConfiguration as? UIListContentConfiguration
        #expect(sut.filmImage == UIImage(systemName: "popcorn"), "Popcorn image means image loading succeeded.")
        #expect(updatedConfig?.image == sut.filmImage, "The cell's image should match the loaded image.")
    }
    
    @Test func exploreListVC_updateCellImage_doesNotSetImageToFilmImage_ifCellWasReused() async {
        let (sut, cell, _) = makeSUTForUpdateCellImageTests(indexPath: IndexPath(item: 1, section: 0))
        let originalIndexPath = IndexPath(item: 0, section: 0)
        
        await sut.updateCellImage(cell, film: .sample, indexPath: originalIndexPath)
        
        let updatedConfig = cell.contentConfiguration as? UIListContentConfiguration
        #expect(updatedConfig?.image == nil, "The updated configuration should be nil as the cell was reused.")
        #expect(cell.imageView.image == UIImage(systemName: "photo"), "The default image should be set as a placeholder.")
    }
    
    @Test func exploreListVC_updateCellImage_usesPlaceholder_whenImageLoadFails() async {
        let (sut, cell, indexPath) = makeSUTForUpdateCellImageTests(shouldSucceed: false)
        
        await sut.updateCellImage(cell, film: .sample, indexPath: indexPath)
        
        let updatedConfig = cell.contentConfiguration as? UIListContentConfiguration
        #expect(updatedConfig?.image != nil, "Should not be nil.")
        #expect(updatedConfig?.image == UIImage(systemName: "photo"), "Placeholder image should be used if image loading fails.")
    }
    
    // MARK: - Helper methods
    fileprivate func makeSUT() -> ExploreListVC {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        return ExploreListVC(viewModel: filmsListViewModel)
    }
    
    fileprivate func createSUTForDataSource() -> ExploreListVC {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let films: [Film] = [.sample]
        sut.didUpdateFilms(films)
        return sut
    }
    
    fileprivate func makeSUTForUpdateCellImageTests(
        shouldSucceed: Bool = true,
        indexPath: IndexPath = IndexPath(item: 0, section: 0)
    ) -> (sut: ExploreListVC, cell: ExploreListCell, indexPath: IndexPath) {
        let mockFilmsListService = MockFilmsListService()
        var imageLoader = MockImageLoader()
        imageLoader.shouldSucceed = shouldSucceed
        
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        let cell = ExploreListCell()
        cell.contentConfiguration = UIListContentConfiguration.cell()
        
        class MockCollectionView: UICollectionView {
            var overrideIndexPath: IndexPath?
            override func indexPath(for cell: UICollectionViewCell) -> IndexPath? { overrideIndexPath }
        }
        
        let mockCV = MockCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        mockCV.overrideIndexPath = indexPath
        sut.collectionView = mockCV
        
        return (sut, cell, indexPath)
    }
    
    // MARK: - Presentation Spies
    fileprivate class PresentationSpy: AlertPresenter {
        var presentedVC: UIViewController?
        var isAnimated: Bool?
        
        func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            self.presentedVC = viewControllerToPresent
            self.isAnimated = flag
            completion?()
        }
    }
    
    fileprivate class SpinnerSpy: SpinnerVC {
        var didMoveToParentWasCalled = false
        var willMoveToParentWasCalled = false
        var capturedParentVC: UIViewController?
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            didMoveToParentWasCalled = true
            capturedParentVC = parent
        }
        
        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            willMoveToParentWasCalled = true
            capturedParentVC = parent
        }
    }
}
