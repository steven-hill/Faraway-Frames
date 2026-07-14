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
    
    @Test("Supplementary View Provider dequeues the segmented control header type")
    func homeVC_collectionView_hasSegmentedControlAsHeaderView() async {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        let kind = UICollectionView.elementKindSectionHeader
//        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath)
        let header = getHeader(sut: sut)
        #expect(header != nil, "Should not be nil.")
    }

    @Test("Empty state is displayed when `Up Next` segment is empty.")
    func homeVC_whenUpNextIsEmpty_displaysUpNextEmptyState() async {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config != nil, "Should be displaying content unavailable view for Up Next films.")
        #expect(sut.films.isEmpty, "Should be empty.")
    }
    
    @Test("Empty state is displayed when `Watched` segment is empty.")
    func homeVC_whenWatchedIsEmpty_displaysWatchedEmptyState() async {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        let kind = UICollectionView.elementKindSectionHeader
//        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? SegmentedControlHeaderView
        let header = getHeader(sut: sut)
        header?.segmentedControl.selectedSegmentIndex = 1
        header?.segmentedControl.sendActions(for: .valueChanged)
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config != nil, "Should be displaying content unavailable view.")
        #expect(sut.films.isEmpty, "Should be empty.")
    }
    
    @Test("Films added to `Up Next` appear in `Up Next` segment")
    func homeVC_whenFilmWasAddedToUpNext_onInit_displaysInUpNext() throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        sut.loadViewIfNeeded()
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config == nil, "Should be displaying Up Next films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 1, "Should be one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the film that was added.")
    }
    
    @Test("Films added to `Watched` appear in `Watched` segment")
    func homeVC_whenFilmWasAddedToWatched_onInit_displaysInWatched() async throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        let kind = UICollectionView.elementKindSectionHeader
//        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? SegmentedControlHeaderView
        let header = getHeader(sut: sut)
        header?.segmentedControl.selectedSegmentIndex = 1
        header?.segmentedControl.sendActions(for: .valueChanged)
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config == nil, "Should be displaying Watched films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 1, "Should be one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the film that was added.")
    }
    
    @Test("When segment changes, snapshot swaps sections to show correct films in their respective segments")
    func homeVC_whenUpNextAndWatchedHaveFilms_onInit_displaysFilmsInCorrectSegments() async throws {
        let (sut, context, entity) = try makeSUTWithContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[1], entity: entity, context: context, isUpNext: true, isWatched: false)
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[2], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        
        sut.loadViewIfNeeded()
        await Task.yield()
        sut.collectionView.layoutIfNeeded()
        
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        #expect(config == nil, "Should be displaying Up Next films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 2, "Should have two films.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the first film that was added.")
        #expect(sut.films[1].id == Film.sample[1].id, "Should be the second film that was added.")
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        let kind = UICollectionView.elementKindSectionHeader
//        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? SegmentedControlHeaderView
        let header = getHeader(sut: sut)
        header?.segmentedControl.selectedSegmentIndex = 1
        header?.segmentedControl.sendActions(for: .valueChanged)
        
        #expect(config == nil, "Should be displaying Watched films, not `contentUnavailableConfiguration`.")
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
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        let kind = UICollectionView.elementKindSectionHeader
//        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? SegmentedControlHeaderView
        let header = getHeader(sut: sut)
        header?.segmentedControl.selectedSegmentIndex = 1
        header?.segmentedControl.sendActions(for: .valueChanged)
        
        #expect(config == nil, "Should be displaying Watched films, not `contentUnavailableConfiguration`.")
        #expect(sut.films.count == 1, "Should have one film.")
        #expect(sut.films[0].id == Film.sample[0].id, "Should be the third film that was added.")
        #expect(sut.films[0].isUpNext == true, "Should be true.")
        #expect(sut.films[0].isWatched == true, "Should be true.")
    }
    
    @Test("Collection view updates layout when device is rotated to landscape.")
    func homeVC_transitionLayout_recreatesCompositionalLayoutWithNewWidth() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let initialLayout = sut.collectionView.collectionViewLayout
        
        sut.transitionLayout(toWidth: 852)
        let updatedLayout = sut.collectionView.collectionViewLayout
        
        #expect(updatedLayout !== initialLayout, "Should instantiate a fresh layout object on size shifts.")
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
    
    // MARK: - SUT Helper Methods
    private func makeSUT() -> HomeVC {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let homeViewModel = HomeViewModel(upNextFRC: mockUpNextFRC, watchedFRC: mockWatchedFRC, filmQueueService: filmQueueService)
        return HomeVC(homeViewModel: homeViewModel)
    }
    
    private func makeSUTWithContextAndEntity() throws -> (sut: HomeVC,
                                                          context: NSManagedObjectContext,
                                                          entity: NSEntityDescription) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let homeVM = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            filmQueueService: filmQueueService)
        let sut = HomeVC(homeViewModel: homeVM)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        return (sut, context, entity)
    }
    
    //MARK: - Collection View Header Helper
    private func getHeader(sut: HomeVC) -> SegmentedControlHeaderView? {
        let indexPath = IndexPath(item: 0, section: 0)
        let kind = UICollectionView.elementKindSectionHeader
        let header = sut.collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? SegmentedControlHeaderView
        return header
    }
}
