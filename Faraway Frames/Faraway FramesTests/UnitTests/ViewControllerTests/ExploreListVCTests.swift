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
    
    @Test func exploreListVC_canUpdateFilmsArraySuccessfully() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        
        #expect(sut.films.count == 22, "VC's film should contain 22 films.")
    }
    
    @Test("ExploreListVC shows error view for all API errors", arguments: [
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func exploreListVC_showsErrorViewForAllErrors(expectedError: APIError) async throws {
        let mockService = MockFilmsListService()
        mockService.result = .failure(expectedError)
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        await sut.viewModel.getAllFilms()
        
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .error(expectedError), "Should set the state to .error.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
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
    
    @Test func exploreListVC_setssearchControllerSearchResultsUpdater() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()

        #expect(sut.searchController.searchResultsUpdater != nil, "Search Results Updater should be set.")
    }
    
    @Test func exploreListVC_searchTextIsEmptyOnInit() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(((sut.searchController.searchBar.text?.isEmpty) != nil), "Search bar text should be nil on init.")
    }
    
    @Test func exploreListVC_searchIsNotAttempted_whenSearchTextIsEmpty() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        sut.searchController.searchBar.text = ""
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.count == 22, "When no search is attempted, the VC's films array should still contain all films.")
    }
    
    @Test func exploreListVC_searchIsNotAttempted_whenFilmsArrayIsEmpty() {
        let sut = makeSUT()

        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.isEmpty, "When no search is attempted, the VC's films array should be empty.")
        #expect(sut.viewModel.films.isEmpty, "View model's films should be empty.")
        #expect(sut.viewModel.filteredFilms.isEmpty, "View model's filtered films should be empty.")
    }
    
    @Test func exploreListVC_showsFilteredResults_whenSearchWasSuccessful() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        sut.searchController.searchBar.text = "Cas"
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.count == 2, "When search successfully finds results, the VC's films array should be updated with those results.")
    }
    
    @Test func exploreListVC_didFailToMatchResults_updatesContentUnavailableConfiguration() {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        sut.loadViewIfNeeded()
        
        sut.didFailToMatchResults()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test func exploreListVC_showsEmptySearchResultsConfig_whenThereAreNoSearchResults() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        sut.searchController.searchBar.text = "No results found"
        sut.updateSearchResults(for: sut.searchController)
        
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .emptySearchResults, "Should set the state to .emptySearchResults.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test func exploreListVC_searchBarCancelButtonTapped_resetsFilmsArrayToAllFilms() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        sut.searchBarCancelButtonClicked(sut.searchController.searchBar)
        
        #expect(sut.films.count == 22, "Should have an array of all films.")
    }
    
    @Test func exploreListVC_searchBarIsNotEnabled_whenLoadingAllFilms() {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .loadingAllFilms, "State should be .loadingAllFilms.")
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
    }
    
    @Test func exploreListVC_searchBarIsEnabled_WhenThereIsFilmsContentFromNetworkCall() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        
        #expect(sut.films.count == 22, "Should have all 22 films to show.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test func exploreListVC_searchBarIsEnabled_WhenThereIsFilmsContentFromSearch() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        sut.searchController.searchBar.text = "Cas"
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.count == 2, "Should have 2 films in search results.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test func exploreListVC_searchBarIsEnabled_WhenThereAreNoSearchResults() async throws {
        let mockFilmsListService = MockServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        sut.searchController.searchBar.text = "No results found"
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.viewModel.filteredFilms.count == 0, "Should have zero films in search results.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test("ExploreListVC search bar is not enabled for all API errors", arguments: [
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError,
        APIError.unknown
    ])
    func exploreListVC_searchBarIsNotEnabledForAllErrors(expectedError: APIError) async throws {
        let mockService = MockFilmsListService()
        mockService.result = .failure(expectedError)
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: imageLoader)
        let sut = ExploreListVC(viewModel: filmsListViewModel)
        
        sut.loadViewIfNeeded()
        await sut.viewModel.getAllFilms()
        
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
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
}
