//
//  HomeVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 22/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit
import CoreData

@MainActor
struct HomeVCTests {
    
    @Test func homeVC_canInitAndLoadView() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func homeVC_onInit_filmsArrayIsEmpty() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.films.isEmpty, "Should be empty on init.")
    }
    
    @Test func homeVC_setsViewModelDelegateToSelf() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.homeViewModel.delegate != nil, "View model's delegate should be set.")
    }
    
    @Test func homeVC_sets_collectionViewDelegate() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.collectionView.delegate != nil, "Collection view's delegate should be set.")
    }
    
    @Test("Datasource returns a `FilmGridCell`")
    func homeVC_dataSource_returnsACell() throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        sut.loadViewIfNeeded()
        
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath) as? FilmGridCell
        let itemCount = sut.collectionView.numberOfItems(inSection: 0)
        
        #expect(cell != nil, "Should successfully return a `FilmGridCell`.")
        #expect(itemCount == 1, "Should be 1 item in the collection view.")
    }
    
    @Test("Empty state view is displayed when `Up Next` segment is empty.")
    func homeVC_whenUpNextIsEmpty_displaysUpNextEmptyState() async {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.emptyStateView.isHidden == false, "Should display empty state view.")
        #expect(sut.films.isEmpty, "Should be empty.")
    }
    
    @Test("Empty state view is displayed when `Watched` segment is empty.")
    func homeVC_whenWatchedIsEmpty_displaysWatchedEmptyState() async {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
        selectSegment(at: 1,
                      in: sut.segmentedControl)
        
        #expect(sut.emptyStateView.isHidden == false, "Should display empty state view.")
        #expect(sut.films.isEmpty, "Should be empty.")
    }
    
    @Test("Film added to `Up Next` appears in `Up Next` segment")
    func homeVC_whenFilmWasAddedToUpNext_onInit_displaysInUpNext() throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        sut.loadViewIfNeeded()
        
        #expect(sut.emptyStateView.isHidden, "Empty state view should be hidden.")
        #expect(sut.films.count == 1, "Should be one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the film that was added.")
    }
    
    @Test("Film added to `Watched` appears in `Watched` segment")
    func homeVC_whenFilmWasAddedToWatched_onInit_displaysInWatched() async throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
        selectSegment(at: 1,
                      in: sut.segmentedControl)
        
        #expect(sut.emptyStateView.isHidden, "Empty state view should be hidden.")
        #expect(sut.films.count == 1, "Should be one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the film that was added.")
    }
    
    @Test("When segment changes, snapshot swaps sections to show correct films in their respective segments")
    func homeVC_whenUpNextAndWatchedHaveFilms_onInit_displaysFilmsInCorrectSegments() async throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0],
                                         entity: entity,
                                         context: context,
                                         isUpNext: true,
                                         isWatched: false)
        try context.save()
        
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[1],
                                         entity: entity,
                                         context: context,
                                         isUpNext: true,
                                         isWatched: false)
        try context.save()
        
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[2],
                                         entity: entity,
                                         context: context,
                                         isUpNext: false,
                                         isWatched: true)
        try context.save()
        
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()

        #expect(sut.emptyStateView.isHidden, "Empty state view should be hidden.")
        #expect(sut.films.count == 2, "Should have two films.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the first film that was added.")
        #expect(sut.films[1].id == Film.sample[1].id, "Should be the second film that was added.")
        
        selectSegment(at: 1,
                      in: sut.segmentedControl)
        
        #expect(sut.emptyStateView.isHidden, "Empty state view should be hidden.")
        #expect(sut.films.count == 1, "Should have one film.")
        #expect(sut.films[0].id == Film.sample[2].id, "Should be the third film that was added.")
    }
    
    @Test("When the same film was added to both queues, and segment selection changes, snapshot shows film in both segments")
    func homeVC_whenSameFilmExistsInBothSegments_eachSegmentDisplaysCorrectData() async throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        try context.save()
        
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config == nil, "Should be displaying Up Next films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 1, "Should have one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the first film that was added.")
        #expect(sut.films[0].isUpNext == true, "Should be true.")
        #expect(sut.films[0].isWatched == true, "Should be true.")
        
        selectSegment(at: 1,
                      in: sut.segmentedControl)
        
        #expect(config == nil, "Should be displaying Watched films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 1, "Should have one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the third film that was added.")
        #expect(sut.films[0].isUpNext == true, "Should be true.")
        #expect(sut.films[0].isWatched == true, "Should be true.")
    }
    
    @Test("If there is an error fetching films from database, alert is shown",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeVC_whenfetchRequestFails_showsAlert(for scenario: (systemError: CocoaError,
                                                                             expectedReason: PersistenceFailureReason)
    ) throws {
        let testPersistenceController = try PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let throwingController = ThrowingFetchedResultsController(context: context, errorToThrow: scenario.systemError)
        let vm = HomeViewModel(
            upNextFRC: throwingController,
            watchedFRC: throwingController,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService
        )
        let sut = HomeVC(homeViewModel: vm)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        sut.loadViewIfNeeded()
        let expectedHomeError = HomeError.fetchFailed(scenario.expectedReason)
        
        #expect(mockPresenter.presentedAlert?.title == expectedHomeError.localizedDescription, "Should match `expectedError`.")
        #expect(mockPresenter.presentedAlert?.message == expectedHomeError.secondaryText, "Should match `expectedError`.")
        #expect(mockPresenter.presentedAlert?.preferredStyle == .alert, "Should be alert.")
        #expect(mockPresenter.presentedAlert?.actions.count == 1, "Should have one.")
        #expect(sut.films.isEmpty, "Should have no films because fetch failed.")
        #expect(sut.emptyStateView.isHidden, "Empty state view should be hidden.")
        #expect(sut.homeViewModel.currentState == .failure(expectedHomeError), "The view model state must match the expected persistence failure scenario exactly.")
    }
    
    @Test("`LayoutMetrics` calculates number of columns for different size classes correctly")
    func homeVC_layoutMetricsColumnCount_returnsCorrectNumberOfColumns() {
        let iPhonePortraitNumberOfColumns = HomeVC.LayoutMetrics.columnCount(horizontal: .compact, vertical: .regular)
        #expect(iPhonePortraitNumberOfColumns == 2)
            
        let iPhoneLandscapeNumberOfColumns = HomeVC.LayoutMetrics.columnCount(horizontal: .compact, vertical: .compact)
        #expect(iPhoneLandscapeNumberOfColumns == 4)

        let iPadFullScreenNumberOfColumns = HomeVC.LayoutMetrics.columnCount(horizontal: .regular, vertical: .regular)
        #expect(iPadFullScreenNumberOfColumns == 4)
        
        let iPadSplitViewNumberOfColumns = HomeVC.LayoutMetrics.columnCount(horizontal: .compact, vertical: .regular)
        #expect(iPadSplitViewNumberOfColumns == 2)
    }
    
    @Test("`FilmGridCell` is reconfigured with film image when image exists in cache.")
    func homeVC_whenImageExistsInCache_reconfiguresCellWithFilmImage() async throws {
        let targetFilm = Film.sample[0]
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: targetFilm, entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        sut.loadViewIfNeeded()

        sut.collectionView.layoutIfNeeded()
        
        await Task.yield()
        let targetIndexPath = IndexPath(item: 0, section: 0)
        guard let cell = sut.collectionView.cellForItem(at: targetIndexPath) as? FilmGridCell else {
            Issue.record("Expected visible `FilmGridCell` to be present after reconfiguration")
            return
        }
        
        #expect(cell.currentDisplayedImage == SFSymbols.popcorn, "The cell should be updated with the cached image (MockImageLoader stubbed to return `SFSymbols.popcorn` in success case).")
    }
    
    @Test("`FilmGridCell` is not reconfigured with film image when image does not exist in cache.")
    func homeVC_whenImageIsNotInCache_cellIsNotReconfiguredWithFilmImage() async throws {
        let targetFilm = Film.sample[0]
        let (sut, context, entity) = try makeSUTWithEmptyMockImageLoaderCache()
        _ = PersistenceHelper.makeFilmMO(with: targetFilm, entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        sut.loadViewIfNeeded()
        
        sut.collectionView.layoutIfNeeded()
        
        await Task.yield()
        let targetIndexPath = IndexPath(item: 0, section: 0)
        guard let cell = sut.collectionView.cellForItem(at: targetIndexPath) as? FilmGridCell else {
            Issue.record("Expected visible `FilmGridCell` to be present after reconfiguration")
            return
        }
        
        #expect(cell.currentDisplayedImage == nil, "Should be nil if image is not in cache.")
    }

    @Test("Tapping a cell in `Up Next` flows through the view model and fires the coordinator delegate")
    func homeVC_didSelectItemAt_filmInUpNext_flowsThroughViewModelToCoordinatorDelegate() async throws {
        let upNextFilm = Film.sample[0]
        let (sut, context, spyDelegate, entity) = try makeSUTForCellTap()
        _ = PersistenceHelper.makeFilmMO(with: upNextFilm,
                                         entity: entity,
                                         context: context,
                                         isUpNext: true,
                                         isWatched: false
        )
        try context.save()
        sut.loadViewIfNeeded()
        sut.collectionView.layoutIfNeeded()
        await Task.yield()
    
        let targetIndexPath = IndexPath(item: 0, section: 0)
        sut.collectionView.delegate?.collectionView?(sut.collectionView, didSelectItemAt: targetIndexPath)
        
        #expect(spyDelegate.didCaptureFilmCallCount == 1, "The tap event should pass through the view model layer to coordinator delegate once.")
        #expect(spyDelegate.capturedFilm?.id == upNextFilm.id, "The correct film should be found by the view model.")
    }
    
    @Test("Tapping a cell in `Watched` flows through the view model and fires the coordinator delegate")
    func homeVC_didSelectItemAt_filmInWatched_flowsThroughViewModelToCoordinatorDelegate() async throws {
        let upNextFilm = Film.sample[0]
        let watchedFilm = Film.sample[1]
        let (sut, context, spyDelegate, entity) = try makeSUTForCellTap()
        _ = PersistenceHelper.makeFilmMO(with: upNextFilm,
                                         entity: entity,
                                         context: context,
                                         isUpNext: true,
                                         isWatched: false
        )
        _ = PersistenceHelper.makeFilmMO(with: watchedFilm,
                                         entity: entity,
                                         context: context,
                                         isUpNext: false,
                                         isWatched: true
        )
        try context.save()
        sut.loadViewIfNeeded()
        sut.collectionView.layoutIfNeeded()
        await Task.yield()
        selectSegment(at: 1,
                      in: sut.segmentedControl)
    
        let targetIndexPath = IndexPath(item: 0, section: 0)
        sut.collectionView.delegate?.collectionView?(sut.collectionView, didSelectItemAt: targetIndexPath)
        
        #expect(spyDelegate.didCaptureFilmCallCount == 1, "The tap event should pass through the view model layer to coordinator delegate once.")
        #expect(spyDelegate.capturedFilm?.id == watchedFilm.id, "The correct film should be found by the view model.")
    }

    // MARK: - SUT Helper Methods
    private func makeSUT() -> HomeVC {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let homeViewModel = HomeViewModel(upNextFRC: mockUpNextFRC,
                                          watchedFRC: mockWatchedFRC,
                                          imageLoader: MockImageLoader(),
                                          filmQueueService: filmQueueService)
        return HomeVC(homeViewModel: homeViewModel)
    }
    
    private func makeSUTWithContextAndEntity() throws -> (sut: HomeVC,
                                                          context: NSManagedObjectContext,
                                                          entity: NSEntityDescription) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let homeVM = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService)
        let sut = HomeVC(homeViewModel: homeVM)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        return (sut, context, entity)
    }
    
    private func makeSUTWithEmptyMockImageLoaderCache() throws -> (sut: HomeVC,
                                                                   context: NSManagedObjectContext,
                                                                   entity: NSEntityDescription) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = false
        let filmQueueService = FilmQueueService(context: context)
        let homeVM = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: mockImageLoader,
            filmQueueService: filmQueueService)
        let sut = HomeVC(homeViewModel: homeVM)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        return (sut, context, entity)
    }
    
    private func makeSUTForCellTap() throws -> (sut: HomeVC,
                                                context: NSManagedObjectContext,
                                                spyDelegate: SpyCoordinatorDelegate,
                                                entity: NSEntityDescription) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let homeVM = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService
        )
        let spyDelegate = SpyCoordinatorDelegate()
        homeVM.coordinatorDelegate = spyDelegate
        let sut = HomeVC(homeViewModel: homeVM)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'.")
        return (sut, context, spyDelegate, entity)
    }
    
    //MARK: - Segmented Control Helper Method
    private func selectSegment(at index: Int,
                               in segmentedControl: UISegmentedControl) {
        segmentedControl.selectedSegmentIndex = index
        segmentedControl.sendActions(for: .valueChanged)
    }
    
    //MARK: - Home View Model Coordinator Delegate Spy
    final class SpyCoordinatorDelegate: HomeViewModelCoordinatorDelegate {
        var didCaptureFilmCallCount = 0
        var capturedFilm: Film?
        
        func homeViewModelDidCaptureFilm(_ film: Film) {
            didCaptureFilmCallCount = 1
            capturedFilm = film
        }
    }
}
