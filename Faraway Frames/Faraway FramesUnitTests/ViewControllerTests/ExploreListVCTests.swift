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
    func exploreListVC_whenLoadingAllFilms_showsLoadingView() async {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        mockFilmsListService.shouldPauseForLoadingStateTest = true
        
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should be showing loading view.")
        #expect(sut.viewModel.currentState == .loadingAllFilms, "State should be `.loadingAllFilms`.")
    }
    
    @Test(.tags(.networkRequest))
    func exploreListVC_afterSuccessfulNetworkCall_updatesUICorrectly() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 22, "Should be 22 films in the collection view.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
        #expect(sut.collectionView.isHidden == false)
        #expect(sut.searchController.searchBar.isEnabled == true)
    }
    
    @Test("ExploreListVC shows alert for all API errors when no archived data exists",
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
    func exploreListVC_showsAlertForAllErrors(expectedError: APIError) async throws {
        let sut = makeSUTForNetworkFailure(error: expectedError)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        sut.loadViewIfNeeded()

        await sut.viewModel.getAllFilms()
        
        #expect(mockPresenter.capturedTitle != nil, "Should not be nil.")
        #expect(mockPresenter.capturedMessage == expectedError.localizedDescription, "Should match `expectedError`.")
        #expect(mockPresenter.capturedActions.count == 1, "Should have one.")
        
        let retryAction = mockPresenter.capturedActions.first
        #expect(retryAction?.title != nil, "Should not be nil.")
        #expect(retryAction?.style == .default, "Should be `.default`.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
        #expect(sut.viewModel.currentState == .error(expectedError), "Should be set to .`error`.")
    }
    
    @Test("ExploreListVC can retry network call from alert",
          .tags(.networkRequest))
    func exploreListVC_retry_callsFetchAllFilms() async {
        let mockService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        
        sut.retryButtonTapped()
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should be showing loading view.")
        #expect(sut.viewModel.currentState == .loadingAllFilms, "Should be set to `.loadingAllFilms`.")
        #expect(sut.viewModel.refreshTask != nil, "Should start a new `refreshTask`.")
        
        await sut.viewModel.refreshTask?.value
        #expect(mockService.fetchWasCalled == true, "Should call fetchAllFilms once.")
    }
    
    @Test(.tags(.networkRequest))
    func exploreListVC_viewWillDisappear_cancelsLoadTask() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let capturedTask = sut.loadTask
        #expect(capturedTask?.isCancelled == false, "Should not be cancelled.")
        #expect(sut.loadTask != nil, "Should not be nil.")
        
        sut.viewWillDisappear(false)
        
        #expect(capturedTask?.isCancelled == true, "Should be marked as cancelled.")
        #expect(sut.loadTask == nil, "Should be nil.")
    }
    
    @Test("VC handles transition from empty search results view back to collection view")
    func exploreListVC_whenSearchBarCancelButtonTapped_returnsToCollectionView() async {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "No results found"
        sut.updateSearchResults(for: sut.searchController)
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil because empty search results view is on screen.")
        #expect(sut.collectionView.isHidden, "Should be hidden.")
        
        sut.searchBarCancelButtonClicked(sut.searchController.searchBar)
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil because the collection view is now on screen.")
        #expect(sut.collectionView.isHidden == false, "Should be on screen.")
    }
    
    @Test func exploreListVC_dataSource_returnsACell() async {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath)
        
        #expect(cell != nil, "Should not be nil.")
    }
    
    @Test func exploreListVC_filmsLookup_populatesCorrectly() async {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
        #expect(sut.filmLookup.count == 22, "Dictionary should have 22 films.")
    }
    
    @Test func exploreListVC_filmsLookup_returnsCorrectFilm() async {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
        #expect(sut.filmLookup["2baf70d1-42bb-4437-b551-e5fed5a87abe"] == sut.viewModel.films.first, "ID should be for 'Castle in the Sky'.")
    }
    
    @Test func exploreListVC_filmsLookup_returnsNilForUnknownID() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        
        #expect(sut.filmLookup["non existent ID"] == nil, "Should return nil if no film with that ID exists.")
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
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 22, "All 22 films should still be in the collection view.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenVMFilmsArrayIsEmpty_searchIsNotAttempted() {
        let sut = makeSUT()
        
        sut.updateSearchResults(for: sut.searchController)
        
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
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 2, "Should be two films in the collection view.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereAreNoSearchResults_showsEmptySearchResultsView() async {
        let sut = makeSUTForNetworkSuccess()
        sut.loadViewIfNeeded()
        await sut.loadTask?.value

        sut.searchController.searchBar.text = "No results found"
        sut.updateSearchResults(for: sut.searchController)
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil because empty search results view is on screen.")
        #expect(sut.viewModel.currentState == .emptySearchResults, "Should set the state to `.emptySearchResults`.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_searchBarCancelButtonTapped_showsAllFilmsAgain() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "Cas"
        sut.updateSearchResults(for: sut.searchController)
        let itemCountAfterSearch = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCountAfterSearch == 2, "Should be two films in the collection view.")
        
        sut.searchBarCancelButtonClicked(sut.searchController.searchBar)
        let itemCountAfterCancel = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCountAfterCancel == 22, "All 22 films should still be in the collection view.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenLoadingAllFilms_searchBarIsNotEnabled() async {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        mockFilmsListService.shouldPauseForLoadingStateTest = true
        
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.view.layoutIfNeeded()
        
        #expect(sut.viewModel.currentState == .loadingAllFilms, "State should be `.loadingAllFilms`.")
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereIsFilmsContentFromNetworkCall_searchBarIsEnabled() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 22, "All 22 films should still be in the collection view.")
        #expect(sut.searchController.searchBar.isEnabled == true, "Should be true.")
    }
    
    @Test(.tags(.search))
    func exploreListVC_whenThereIsFilmsContentFromSearch_searchBarIsEnabled() async {
        let sut = makeSUTForNetworkSuccess()
        
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        sut.searchController.searchBar.text = "Cas"
        sut.updateSearchResults(for: sut.searchController)
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(itemCount == 2, "Should be 2 films in the collection view.")
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
    
    @Test("ExploreListVC search bar is not enabled for all API errors",
        .tags(.search),
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
    func exploreListVC_searchBarIsNotEnabledForAllErrors(expectedError: APIError) async throws {
        let sut = makeSUTForNetworkFailure(error: expectedError)
        
        sut.loadViewIfNeeded()
        await sut.viewModel.getAllFilms()
        
        sut.view.layoutIfNeeded()
        
        #expect(sut.searchController.searchBar.isEnabled == false, "Should be false.")
    }
    
    @Test func exploreListVC_didSelectItemAt_notifiesDelegate_withCorrectFilm() async {
        let sut = makeSUTForNetworkSuccess()
        let spy = ExploreNavigationSpy()
        sut.navigationDelegate = spy
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
                
        let indexPath = IndexPath(item: 0, section: 0)
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(spy.didSelectFilmCalled, "Delegate should be called.")
        #expect(spy.selectedFilm?.id == sut.viewModel.films[0].id, "Both ids should match.")
        #expect(spy.selectedFilm?.title == "Castle in the Sky", "Should be `Castle in the Sky`.")
    }
    
    @Test func exploreListVC_whenIndexPathIsInvalid_didSelectItemAt_doesNotNotifyDelegate() async {
        let sut = makeSUTForNetworkSuccess()
        let spy = ExploreNavigationSpy()
        sut.navigationDelegate = spy
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
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
    func exploreListVC_didSelectItemAt_deselectsItem() async {
        let sut = makeSUTForNetworkSuccess()
        let spy = ExploreNavigationSpy()
        spy.shouldDeselectAfterSelection = true
        sut.navigationDelegate = spy
        sut.loadViewIfNeeded()
        await sut.loadTask?.value

        let indexPath = IndexPath(item: 0, section: 0)
        sut.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        #expect(sut.collectionView.indexPathsForSelectedItems?.isEmpty == true, "Should be empty.")
    }
    
    @Test("iPad only: collection view cell stays selected after selection", .enabled(if: IpadHelper.isPad))
    func exploreListVC_didSelectItemAt_keepsItemSelected() async {
        let sut = makeSUTForNetworkSuccess()
        let spy = ExploreNavigationSpy()
        spy.shouldDeselectAfterSelection = false
        sut.navigationDelegate = spy
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        
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
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()

        sut.collectionView.refreshControl?.sendActions(for: .valueChanged)
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should be showing loading view.")
        #expect(sut.viewModel.currentState == .loadingAllFilms, "Should be set to `.loadingAllFilms`.")
        
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
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)

        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        let indexPath = IndexPath(item: 0, section: 0)
        let kind = UICollectionView.elementKindSectionHeader
        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath)
            
        #expect(header != nil, "Should not be nil.")
        #expect(header is NetworkErrorHeaderView, "Should be the custom header view.")
    }
    
    @Test("When data in File Manager is not being used, collection view has no header view.")
    func exploreListVC_whenFileManagerDataIsNotUsed_doesNotShowCollectionViewHeader() async {
        let mockFilmsListService = MockFilmsListService()
        mockFilmsListService.isUsingFileManagerData = false
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        
        sut.loadViewIfNeeded()
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
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let mockDetailVM = FilmDetailViewModel(imageLoader: imageLoader,
                                               managedObjectContext: testPersistenceController.viewContext,
                                               frcFactory: MockFRCFactory(),
                                               filmQueueService: filmQueueService
                                               )
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
        
        sut.viewModel(
            sut.viewModel,
            didEmit: FilmsListViewModel.FilmsListEvent.voiceOverAnnouncement("test")
        )
        
        #expect(sut.voiceOverAnnouncementTask == nil, "Should be nil due to early exit via guard.")
        #expect(mockAccessibilityService.postedNotification == nil, "Should not have posted a notification.")
        #expect(mockAccessibilityService.postedArgument as? String == nil, "Should be no argument.")
        #expect(mockAccessibilityService.postCallCount == 0, "Should not have been called.")
    }
    
    @Test("Posts notification with message after the debounce delay completes")
    func exploreListVC_didRequestVoiceOverAnnouncement_whenVoiceOverIsOn_postsMessageAfterDelay() async throws {
        let (sut, mockAccessibilityService) = await makeSUTForVOTests(voiceOverIsOn: true)
        
        sut.viewModel(
            sut.viewModel,
            didEmit: FilmsListViewModel.FilmsListEvent.voiceOverAnnouncement("Test Announcement")
        )
        await mockAccessibilityService.waitForNotification()
        
        #expect(mockAccessibilityService.postedNotification == .announcement, "The notification should be for an announcement.")
        #expect(mockAccessibilityService.postedArgument as? String == "Test Announcement", "Should match the call's input.")
        #expect(mockAccessibilityService.postCallCount == 1, "Should have been called once.")
        #expect(sut.voiceOverAnnouncementTask == nil, "Should be set to nil after posting.")
    }
    
    @Test("Cancels previous announcement task when a new one is requested rapidly")
    func exploreListVC_didRequestVoiceOverAnnouncement_multipleRequests_cancelsPreviousAndDebounces() async throws {
        let (sut, mockAccessibilityService) = await makeSUTForVOTests(voiceOverIsOn: true)
        
        sut.viewModel(
            sut.viewModel,
            didEmit: FilmsListViewModel.FilmsListEvent.voiceOverAnnouncement("First Message")
        )
        let firstTask = sut.voiceOverAnnouncementTask
        
        sut.viewModel(
            sut.viewModel,
            didEmit: FilmsListViewModel.FilmsListEvent.voiceOverAnnouncement("Second Message")
        )
        await mockAccessibilityService.waitForNotification()
        
        #expect(firstTask?.isCancelled == true, "Should have cancelled the first task.")
        #expect(mockAccessibilityService.postedArgument as? String == "Second Message", "Should match input of second call.")
        #expect(mockAccessibilityService.postedNotification == .announcement, "The notification should be for an announcement.")
        #expect(mockAccessibilityService.postCallCount == 1, "Due to task cancellation, only one announcement was made.")
    }
    
    @Test("Clean up `voiceOverAnnouncementTask` in `viewWillDisappear`")
    func exploreListVC_viewWillDisappear_cancelsVoiceOverTaskAndSetsItToNil() async {
        let (sut, mockAccessibilityService) = await makeSUTForVOTests(voiceOverIsOn: true)

        sut.viewModel(
            sut.viewModel,
            didEmit: FilmsListViewModel.FilmsListEvent.voiceOverAnnouncement("Message")
        )
        
        let capturedTask = sut.voiceOverAnnouncementTask
        #expect(capturedTask?.isCancelled == false, "Should not be cancelled.")
        #expect(sut.loadTask != nil, "Should not be nil.")
        
        sut.viewWillDisappear(false)
        
        #expect(capturedTask?.isCancelled == true, "Should be marked for cancellation.")
        #expect(sut.voiceOverAnnouncementTask == nil, "Should be nil.")
        #expect(mockAccessibilityService.postCallCount == 0, "Due to task cancellation, no announcement was made.")
    }
    
    // MARK: - SUT Helper Methods
    private func makeSUT() -> ExploreListVC {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        return ExploreListVC(viewModel: filmsListViewModel,
                             cellConfigurator: mockCellConfigurator,
                             accessibilityService: mockAccessibilityService)
    }
    
    private func makeSUTForNetworkSuccess() -> ExploreListVC {
        let mockFilmsListService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        return ExploreListVC(viewModel: filmsListViewModel,
                             cellConfigurator: mockCellConfigurator,
                             accessibilityService: mockAccessibilityService)
    }
    
    private func makeSUTForNetworkFailure(error: APIError) -> ExploreListVC {
        let mockService = MockFilmsListService()
        mockService.result = .failure(error)
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        return ExploreListVC(viewModel: filmsListViewModel,
                             cellConfigurator: mockCellConfigurator,
                             accessibilityService: mockAccessibilityService)
    }
    
    private func makeSUTForVOTests(voiceOverIsOn: Bool) async -> (sut: ExploreListVC, mockAccessibilityService: MockAccessibilityService) {
        let mockFilmsListService = MockFilmsListServiceHelper.setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService,
                                                    imageLoader: imageLoader,
                                                    filmSyncService: filmSyncService)
        let mockCellConfigurator = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        let mockAccessibilityService = MockAccessibilityService()
        mockAccessibilityService.isVoiceOverRunningStub = voiceOverIsOn
        let sut = ExploreListVC(viewModel: filmsListViewModel,
                                cellConfigurator: mockCellConfigurator,
                                accessibilityService: mockAccessibilityService)
        sut.loadViewIfNeeded()
        await sut.loadTask?.value
        return (sut, mockAccessibilityService)
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
