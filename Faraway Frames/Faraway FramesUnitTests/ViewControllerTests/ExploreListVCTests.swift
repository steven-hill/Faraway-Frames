//
//  ExploreListVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 18/01/2026.
//

import Testing
import UIKit
import SwiftUI
@testable import Faraway_Frames

@MainActor
struct ExploreListVCTests {
    
    @Test func exploreListVC_canLoadView() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "Should not be nil.")
    }
    
    @Test func exploreListVC_isInsideANavigationController() {
        let sut = makeSUT()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
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
    
    @Test func exploreListVC_setsCollectionViewDelegateAndDataSource() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.collectionView.delegate != nil, "Collection view delegate should be set.")
        #expect(sut.collectionView.dataSource != nil, "Collection view data source should be set.")
    }
    
    @Test(.tags(.networkRequest))
    func exploreListVC_canUpdateFilmsArraySuccessfullyAndUpdateUI() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
        #expect(sut.films.count == 22, "VC's film should contain 22 films.")
        #expect(sut.viewModel.currentState == .content(isUsingArchivedData: false), "Should set the state to .content.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
        #expect(sut.collectionView.isHidden == false)
        #expect(sut.searchController.searchBar.isEnabled == true)
    }
    
    @Test("ExploreListVC shows error view for all API errors", .tags(.networkRequest), arguments: [
        APIError.noInternetConnection,
        APIError.networkConnectionLost,
        APIError.networkTimeout,
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError(""),
        APIError.unknown
    ])
    func exploreListVC_showsErrorViewForAllErrors(expectedError: APIError) async {
        let sut = makeSUTForNetworkFailure(error: expectedError)
        
        sut.loadViewIfNeeded()
        await sut.viewModel.getAllFilms()
        
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .error(expectedError), "Should set the state to .error.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test(.tags(.networkRequest))
    func exploreListVC_retry_callsFetchAllFilms() async {
        let mockService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        
        sut.loadViewIfNeeded()
        sut.viewModel.retryLoadingAllFilms()
        await sut.viewModel.refreshTask?.value
        
        #expect(mockService.fetchWasCalled == true, "Should call fetchAllFilms once.")
    }
    
    @Test("ExploreListVC shows retry button title for all API errors, and when tapped, starts retrying network request",
        .tags(.networkRequest),
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
    func exploreListVC_forAllErrors_showsRetryButtonTitle_andWhenTappedStartsRetrying(expectedError: APIError) async {
        let sut = makeSUTForNetworkFailure(error: expectedError)
        sut.loadViewIfNeeded()
        
        await sut.viewModel.getAllFilms()
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        
        #expect(config != nil, "Should not be nil.")
        #expect(config?.button.title != nil, "Should have a title.")
        
        config?.buttonProperties.primaryAction?.performWithSender(nil, target: nil)
        
        #expect(sut.viewModel.currentState == .retrying, "Should be set to `.retrying`.")
        #expect(sut.viewModel.refreshTask != nil, "Should start a new `refreshTask`.")
    }
    
    @Test(.tags(.networkRequest))
    func exploreListVC_viewWillDisappear_cancelsLoadTask() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let capturedTask = sut.loadTask
        
        sut.viewWillDisappear(false)
        
        #expect(capturedTask?.isCancelled == true, "Should be marked as cancelled.")
        #expect(sut.loadTask == nil, "Should be nil.")
    }
    
    @Test func exploreListVC_didUpdateFilms_updatesCollectionViewItemCount() {
        let sut = makeSUTForDataSource()
        
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 1, "Should be 1 item in the collection view.")
    }
    
    @Test func exploreListVC_dataSource_returnsACell() {
        let sut = makeSUTForDataSource()
        
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath)
        
        #expect(cell != nil, "Should not be nil.")
    }
    
    @Test func exploreListVC_filmsLookup_populatesCorrectly() {
        let sut = makeSUTForDataSource()
        
        #expect(sut.filmLookup.count == 1, "Dictionary should have 1 film.")
    }
    
    @Test func exploreListVC_filmsLookup_returnsCorrectFilm() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let films: [Film] = [Film.sample[0]]
        
        sut.didUpdateFilms(films)
        
        #expect(sut.filmLookup["2baf70d1-42bb-4437-b551-e5fed5a87abe"] != nil, "Should not be nil.")
        #expect(sut.filmLookup["2baf70d1-42bb-4437-b551-e5fed5a87abe"] == films.first, "ID should be for 'Castle in the Sky'.")
        #expect(sut.filmLookup.first?.value.title == "Castle in the Sky", "Title should be 'Castle in the Sky'.")
    }
    
    @Test func exploreListVC_filmsLookup_returnsNilForUnknownID() {
        let sut = makeSUTForDataSource()
        
        #expect(sut.filmLookup["non existent ID"] == nil, "Should return nil if no film with that ID exists.")
    }
    
    @Test func exploreListVC_updateCellImage_whenImageLoadingSucceeds_setsCellContentConfigurationCorrectly() async {
        let (sut, cell, film, indexPath) = makeSUTForUpdateCellImageTests(shouldSucceed: true, dataSourceFilmID: "2baf70d1-42bb-4437-b551-e5fed5a87abe")
        
        await sut.updateCellImage(cell, filmID: film.id, indexPath: indexPath)
        
        #expect(cell.contentConfiguration is UIHostingConfiguration<FilmRowView, EmptyView>, "Cell should have been updated with `UIHostingConfiguration` and `FilmRowView`.")
    }
    
    @Test func exploreListVC_updateCellImage_whenFilmIDDoesNotMatchIndexPath_cellContentConfigurationIsNotUpdated() async {
        let (sut, cell, film, indexPath) = makeSUTForUpdateCellImageTests(shouldSucceed: true, dataSourceFilmID: "Mismatch")
                
        await sut.updateCellImage(cell, filmID: film.id, indexPath: indexPath)
       
        #expect(cell.contentConfiguration is UIHostingConfiguration<FilmRowView, EmptyView>, "Should have the original configuration because the IDs did not match.")
    }
    
    @Test func exploreListVC_updateCellImage_whenImageLoadFails_setsCellContentConfigurationCorrectly() async {
        let (sut, cell, film, indexPath) = makeSUTForUpdateCellImageTests(shouldSucceed: false, dataSourceFilmID: "2baf70d1-42bb-4437-b551-e5fed5a87abe")
        
        await sut.updateCellImage(cell, filmID: film.id, indexPath: indexPath)
        
        #expect(cell.contentConfiguration is UIHostingConfiguration<FilmRowView, EmptyView>, "Cell should have been updated with `UIHostingConfiguration` and `FilmRowView`.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_setsSearchControllerSearchResultsUpdater() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.searchController.searchResultsUpdater != nil, "Search Results Updater should be set.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_searchTextIsEmptyOnInit() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(((sut.searchController.searchBar.text?.isEmpty) != nil), "Search bar text should be nil on init.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenSearchTextIsEmpty_searchIsNotAttempted() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = ""
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.count == 22, "When no search is attempted, the VC's films array should still contain all films.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenFilmsArrayIsEmpty_searchIsNotAttempted() {
        let sut = makeSUT()
        
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.isEmpty, "When no search is attempted, the VC's films array should be empty.")
        #expect(sut.viewModel.films.isEmpty, "View model's films should be empty.")
        #expect(sut.viewModel.filteredFilms.isEmpty, "View model's filtered films should be empty.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenSearchWasSuccessful_showsFilteredResults() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "Cas"
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.count == 2, "When search successfully finds results, the VC's films array should be updated with those results.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_didFailToMatchResults_updatesContentUnavailableConfiguration() {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        
        sut.didFailToMatchResults()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereAreNoSearchResults_showsEmptySearchResultsConfig() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "No results found"
        sut.updateSearchResults(for: sut.searchController)
        
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .emptySearchResults, "Should set the state to .emptySearchResults.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_searchBarCancelButtonTapped_resetsFilmsArrayToAllFilms() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchBarCancelButtonClicked(sut.searchController.searchBar)
        
        #expect(sut.films.count == 22, "Should have an array of all films.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenViewModelStateIsIdle_searchBarIsNotEnabled() {
        let sut = makeSUT()
        
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .idle, "State should be .idle.")
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenLoadingAllFilms_searchBarIsNotEnabled() async {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        mockFilmsListService.shouldPauseForLoadingStateTest = true
        
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .loadingAllFilms, "State should be .loadingAllFilms.")
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereIsFilmsContentFromNetworkCall_searchBarIsEnabled() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
        #expect(sut.films.count == 22, "Should have all 22 films to show.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereIsFilmsContentFromSearch_searchBarIsEnabled() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "Cas"
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.films.count == 2, "Should have 2 films in search results.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereAreNoSearchResults_searchBarIsEnabled() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "No results found"
        sut.updateSearchResults(for: sut.searchController)
        
        #expect(sut.viewModel.filteredFilms.count == 0, "Should have zero films in search results.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test("ExploreListVC search bar is not enabled for all API errors", .tags(.search), arguments: [
        APIError.noInternetConnection,
        APIError.networkConnectionLost,
        APIError.networkTimeout,
        APIError.invalidURL,
        APIError.invalidResponse,
        APIError.serverError(statusCode: 500),
        APIError.decodingError(""),
        APIError.unknown
    ])
    func exploreListVC_searchBarIsNotEnabledForAllErrors(expectedError: APIError) async throws {
        let sut = makeSUTForNetworkFailure(error: expectedError)
        
        sut.loadViewIfNeeded()
        await sut.viewModel.getAllFilms()
        
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
    }
    
    @Test func exploreListVC_didSelectItemAt_notifiesDelegate_withCorrectFilm() {
        let sut = makeSUT()
        let spy = ExploreNavigationSpy()
        sut.navigationDelegate = spy
        let testFilm = Film.sample[0]
        let films = [testFilm]
        sut.loadViewIfNeeded()
        sut.didUpdateFilms(films)
        let indexPath = IndexPath(item: 0, section: 0)
        
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(spy.didSelectFilmCalled, "Delegate should be called.")
        #expect(spy.selectedFilm?.id == testFilm.id, "Both ids should match.")
        #expect(spy.selectedFilm?.title == "Castle in the Sky", "Should be `Castle in the Sky`.")
    }
    
    @Test func exploreListVC_whenIndexPathIsInvalid_didSelectItemAt_doesNotNotifyDelegate() {
        let sut = makeSUT()
        let spy = ExploreNavigationSpy()
        sut.navigationDelegate = spy
        let testFilm = Film.sample[0]
        let films = [testFilm]
        sut.loadViewIfNeeded()
        sut.didUpdateFilms(films)
        
        let indexPath = IndexPath(item: 99, section: 0)
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(spy.didSelectFilmCalled == false, "Should be false.")
    }
    
    @Test func exploreListVC_whenFilmIsMissingFromLookup_didSelectItemAt_doesNotNotifyDelegate() async {
        let sut = makeSUT()
        let spy = ExploreNavigationSpy()
        sut.navigationDelegate = spy
        let testID = Film.ID()
        sut.loadViewIfNeeded()
        var snapshot = NSDiffableDataSourceSnapshot<ExploreListVC.Section, Film.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems([testID], toSection: .main)
        await sut.dataSource.apply(snapshot, animatingDifferences: false)
        
        let indexPath = IndexPath(item: 0, section: 0)
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(spy.didSelectFilmCalled == false, "Should be false.")
    }
    
    @Test("iPhone only: collection view cell deselects after selection", .disabled(if: IpadHelper.isPad))
    func exploreListVC_didSelectItemAt_deselectsItem() {
        let sut = makeSUT()
        let spy = ExploreNavigationSpy()
        spy.shouldDeselectAfterSelection = true
        sut.navigationDelegate = spy
        let testFilm = Film.sample[0]
        let films = [testFilm]
        sut.loadViewIfNeeded()
        sut.didUpdateFilms(films)
        
        let indexPath = IndexPath(item: 0, section: 0)
        sut.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(sut.collectionView.indexPathsForSelectedItems?.isEmpty == true, "Should be empty.")
    }
    
    @Test("iPad only: collection view cell stays selected after selection", .enabled(if: IpadHelper.isPad))
    func exploreListVC_didSelectItemAt_keepsItemSelected() {
        let sut = makeSUT()
        let spy = ExploreNavigationSpy()
        sut.navigationDelegate = spy
        let testFilm = Film.sample[0]
        let films = [testFilm]
        sut.loadViewIfNeeded()
        sut.didUpdateFilms(films)
        
        let indexPath = IndexPath(item: 0, section: 0)
        sut.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(sut.collectionView.indexPathsForSelectedItems?.isEmpty == false, "Should not be empty.")
    }
    
    @Test("Refresh control is configured correctly")
    func exploreListVC_viewDidLoad_configuresRefreshControl() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.collectionView.refreshControl != nil, "Refresh control should not be nil.")
    }
    
    @Test("Pull to refresh retries loading all films")
    func exploreListVC_pullToRefresh_retriesLoadingAllFilms() async {
        let mockService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        
        sut.loadViewIfNeeded()
        sut.collectionView.refreshControl?.sendActions(for: .valueChanged)
        #expect(sut.viewModel.currentState == .retrying, "Should be set to `.retrying`.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
        await sut.viewModel.refreshTask?.value
        
        #expect(mockService.fetchWasCalled == true, "Should call fetchAllFilms.")
    }
    
    @Test("Pull to refresh updates Content Unavailable Configuration")
    func exploreListVC_pullToRefresh_updatesContentUnavailableConfiguration() {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        
        sut.collectionView.refreshControl?.sendActions(for: .valueChanged)

        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }

    @Test("Refreshing stops when films have loaded")
    func exploreListVC_didUpdateFilms_stopsRefreshing() {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        
        sut.collectionView.refreshControl?.sendActions(for: .valueChanged)
        let films: [Film] = [Film.sample[0]]
        sut.didUpdateFilms(films)
        
        #expect(sut.collectionView.refreshControl?.isRefreshing == false, "Should be false.")
    }
    
    @Test("Refreshing stops when failed to load films")
    func exploreListVC_didFailToLoadFilms_stopsRefreshing() {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        
        sut.collectionView.refreshControl?.sendActions(for: .valueChanged)
        sut.didFailToLoadFilms()
        
        #expect(sut.collectionView.refreshControl?.isRefreshing == false, "Should be false.")
    }
    
    @Test("When there is a network error and data in File Manager is being used, collection view displays supplementary header view.")
    func exploreListVC_whenShowingDataFromFileManager_setsHeaderModeToSupplementary() async {
        let mockFilmsListService = MockFilmsListService()
        mockFilmsListService.isUsingFileManagerData = true
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        let films: [Film] = [Film.sample[0]]

        sut.didUpdateFilms(films)
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        let indexPath = IndexPath(item: 0, section: 0)
        let kind = UICollectionView.elementKindSectionHeader
        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath)
            
        #expect(header != nil, "Should not be nil.")
        #expect(header is NetworkErrorReusableView, "Should be the custom header view.")
    }
    
    @Test("When data in File Manager is not being used, collection view has no header view.")
    func exploreListVC_whenFileManagerDataIsNotUsed_doesNotShowCollectionViewHeader() async {
        let mockFilmsListService = MockFilmsListService()
        mockFilmsListService.isUsingFileManagerData = false
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        
        let films: [Film] = [Film.sample[0]]
        sut.didUpdateFilms(films)
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
        let indexPath = IndexPath(item: 0, section: 0)
        let kind = UICollectionView.elementKindSectionHeader
        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath)
            
        #expect(header == nil, "Should be nil.")
    }
    
    @Test("`filmDetailViewController` delegate method correctly routes the updated film to FilmsListViewModel")
    func exploreListVC_filmDetailViewController_routesUpdatedFilmToFilmsListViewModel() async {
        let initialFilm = Film.sample[0]
        let mockFilmsListService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let mockDetailVM = FilmDetailViewModel(imageLoader: imageLoader, filmQueueService: filmQueueService)
        let dummyDetailVC = ExploreDetailVC(filmDetailViewModel: mockDetailVM)
        
        var mutatedFilm = initialFilm
        mutatedFilm.isWatched = true
        sut.filmDetailViewController(dummyDetailVC, didUpdateFilm: mutatedFilm)
        
        if let mutatedFilmInFilmsArray = filmsListViewModel.films.first(where: { $0.id == initialFilm.id }) {
            #expect(mutatedFilmInFilmsArray.isWatched == true, "The delegate function should successfully trigger viewModel.updateFilmInArrays(_:) to change the flag.")
        } else {
            Issue.record("The film with ID 'initialFilm.id' was missing entirely from the films array.")
        }
    }
    
    @Test("Does not post announcement when VoiceOver is disabled")
    func exploreListVC_didRequestVoiceOverAnnouncement_whenVoiceOverIsDisabled_doesNotPost() async {
        let (sut, mockAccessibilityService) = await makeSUTForVOTests(voiceOverIsOn: false)
        
        sut.didRequestVoiceOverAnnouncement(with: "test")
        
        #expect(sut.voiceOverAnnouncementTask == nil, "Should be nil due to early exit via guard.")
        #expect(mockAccessibilityService.postedNotification == nil, "Should not have posted a notification.")
        #expect(mockAccessibilityService.postedArgument as? String == nil, "Should be no argument.")
        #expect(mockAccessibilityService.postCallCount == 0, "Should not have been called.")
    }
    
    @Test("Posts notification with message after the debounce delay completes")
    func exploreListVC_didRequestVoiceOverAnnouncement_whenVoiceOverIsOn_postsMessageAfterDelay() async throws {
        let (sut, mockAccessibilityService) = await makeSUTForVOTests(voiceOverIsOn: true)
        
        sut.didRequestVoiceOverAnnouncement(with: "Test Announcement")
        try await Task.sleep(nanoseconds: 600_000_000)
        
        #expect(mockAccessibilityService.postedNotification == .announcement, "The notification should be for an announcement.")
        #expect(mockAccessibilityService.postedArgument as? String == "Test Announcement", "Should match the call's input.")
        #expect(mockAccessibilityService.postCallCount == 1, "Should have been called once.")
    }
    
    @Test("Cancels previous announcement task when a new one is requested rapidly")
    func exploreListVC_didRequestVoiceOverAnnouncement_multipleRequests_cancelsPreviousAndDebounces() async throws {
        let (sut, mockAccessibilityService) = await makeSUTForVOTests(voiceOverIsOn: true)
        
        sut.didRequestVoiceOverAnnouncement(with: "First Message")
        let firstTask = sut.voiceOverAnnouncementTask
        sut.didRequestVoiceOverAnnouncement(with: "Second Message")
        try await Task.sleep(nanoseconds: 600_000_000)
        
        #expect(firstTask?.isCancelled == true, "Should have cancelled the first task.")
        #expect(mockAccessibilityService.postedArgument as? String == "Second Message", "Should match input of second call.")
        #expect(mockAccessibilityService.postedNotification == .announcement, "The notification should be for an announcement.")
        #expect(mockAccessibilityService.postCallCount == 1, "Due to task cancellation, only one announcement was made.")
    }
    
    // MARK: - SUT Helper Methods
    private func makeSUT() -> ExploreListVC {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        return ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
    }
    
    private func makeSUTForNetworkSuccess() -> ExploreListVC {
        let mockFilmsListService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        return ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
    }
    
    private func makeSUTForNetworkFailure(error: APIError) -> ExploreListVC {
        let mockService = MockFilmsListService()
        mockService.result = .failure(error)
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        return ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
    }
    
    private func makeSUTForDataSource() -> ExploreListVC {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let films: [Film] = [Film.sample[0]]
        sut.didUpdateFilms(films)
        return sut
    }
    
    private func makeSUTForUpdateCellImageTests(
        shouldSucceed: Bool,
        indexPath: IndexPath = IndexPath(item: 0, section: 0),
        dataSourceFilmID: String
    ) -> (sut: ExploreListVC, cell: UICollectionViewListCell, film: Film, indexPath: IndexPath) {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        imageLoader.shouldSucceed = shouldSucceed
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        let film = Film.sample[0]
        let cell = UICollectionViewListCell()
        cell.contentConfiguration = UIHostingConfiguration {
            FilmRowView(film: film, image: nil)
        }
        
        let mockCV = MockCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        mockCV.knownCell = cell
        mockCV.knownIndexPath = indexPath
        sut.collectionView = mockCV

        let mockDataSource = MockDataSource()
        mockDataSource.mockItemID = dataSourceFilmID
        sut.dataSource = mockDataSource
        
        sut.didUpdateFilms([film])
        return (sut, cell, film, indexPath)
    }
    
    private func makeSUTForVOTests(voiceOverIsOn: Bool) async -> (sut: ExploreListVC, mockAccessibilityService: MockAccessibilityService) {
        let mockFilmsListService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        mockAccessibilityService.isVoiceOverRunningStub = voiceOverIsOn
        let sut = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        return (sut, mockAccessibilityService)
    }
    
    // MARK: - Mock CollectionView
    private final class MockCollectionView: UICollectionView {
        var knownCell: UICollectionViewCell?
        var knownIndexPath: IndexPath?
        
        override func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
            return (cell === knownCell) ? knownIndexPath : nil
        }
    }
    
    // MARK: - Mock DataSource
    private final class MockDataSource: UICollectionViewDiffableDataSource<ExploreListVC.Section, Film.ID> {
        var mockItemID: Film.ID?
        
        override func itemIdentifier(for indexPath: IndexPath) -> Film.ID? {
            return mockItemID
        }
        
        init() {
            let dummyCV = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            super.init(collectionView: dummyCV) { _, _, _ in
                UICollectionViewListCell()
            }
        }
    }
    
    // MARK: - Explore Navigation Delegate Spy
    private final class ExploreNavigationSpy: ExploreNavigationDelegate {
        var shouldDeselectAfterSelection = false
        var selectedFilm: Film?
        var didSelectFilmCalled = false
        
        var onDidSelectFilmCalled: (@Sendable (Film) -> Void)?
        
        func didSelectFilm(_ film: Film) {
            selectedFilm = film
            didSelectFilmCalled = true
            onDidSelectFilmCalled?(film)
        }
    }
}
