//
//  ExploreSplitViewCoordinatorTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 03/02/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct ExploreSplitViewCoordinatorTests {
    
    @Test func exploreSplitViewCoordinator_start_setsDelegateCorrectly() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(),
                                              imageLoader: MockImageLoader(),
                                              filmQueueService: filmQueueService,
                                              filmSyncService: filmSyncService,
                                              exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        #expect(sut.exploreSplitVC.delegate != nil, "Should not be nil.")
    }
    
    @Test func exploreSplitViewCoordinator_setsUpPrimaryVCCorrectly() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(),
                                              imageLoader: MockImageLoader(),
                                              filmQueueService: filmQueueService,
                                              filmSyncService: filmSyncService,
                                              exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        let primary = exploreSplitVCSpy.viewController(for: .primary)
        #expect(primary is UINavigationController)
        #expect((primary as? UINavigationController)?.topViewController is ExploreListVC)
    }
    
    @Test func exploreSplitViewCoordinator_setsUpSecondaryVCCorrectly() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(),
                                              imageLoader: MockImageLoader(),
                                              filmQueueService: filmQueueService,
                                              filmSyncService: filmSyncService,
                                              exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        let secondary = exploreSplitVCSpy.viewController(for: .secondary)
        #expect(secondary is UINavigationController)
        #expect((secondary as? UINavigationController)?.topViewController is ExploreDetailVC)
    }
    
    @Test func exploreSplitViewCoordinator_returnsCorrectColumnFromDelegate() {
        let sut = makeSUT(with: ExploreSplitVCSpy())
        
        let result = sut.splitViewController(sut.exploreSplitVC, topColumnForCollapsingToProposedTopColumn: .primary)
        
        #expect(result == .primary, "Should display the primary column after the split view interface collapses.")
    }
    
    @Test("iPhone only: collection view cell deselects after selection", .disabled(if: IpadHelper.isPad))
    func exploreSplitViewCoordinator_shouldDeselectAfterSelection() {
        let exploreSplitVCSpy = CollapsedSplitViewSpy()
        let sut = makeSUT(with: exploreSplitVCSpy)

        #expect(sut.shouldDeselectAfterSelection == true, "Should be true.")
    }
    
    @Test("iPad only: collection view cell keeps selection after being selected", .enabled(if: IpadHelper.isPad))
    func exploreSplitViewCoordinator_shouldKeepSelectionAfterSelection() {
        let exploreSplitVCSpy = ExpandedSplitViewSpy()
        let sut = makeSUT(with: exploreSplitVCSpy)

        #expect(sut.shouldDeselectAfterSelection == false, "Should be false.")
    }
    
    @Test("iPad only: two view controllers are displayed", .enabled(if: IpadHelper.isPad))
    func exploreSplitViewCoordinator_didSelectFilm_withFilm_createsExploreDetailVCAndSetsDelegate() {
        let spy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = makeSUT(with: spy)
        sut.start()
        let film = Film.sample[0]
        
        sut.didSelectFilm(film)
        
        #expect(spy.viewControllers.count == 2, "Should be 2 view controllers.")
        
        guard let detailVC = spy.viewController(for: .secondary) as? ExploreDetailVC else {
            Issue.record("The secondary view controller must be an instance of `ExploreDetailVC`.")
            return
        }
        
        guard let primaryNav = spy.viewController(for: .primary) as? UINavigationController,
              let expectedListVC = primaryNav.viewControllers.first as? ExploreListVC else {
            Issue.record("The primary view controller navigation stack is unconfigured or wrong type.")
            return
        }
        
        #expect(detailVC.delegate === expectedListVC, "The detail view controller delegate must be set to the ExploreListVC instance.")
    }
    
    @Test("iPad only: collection view cell keeps selection after being selected", .enabled(if: IpadHelper.isPad))
    func exploreSplitViewCoordinator_didSelectFilm_withFilm_collapsesPrimaryViewController() {
        let exploreSplitVCSpy = ExpandedSplitViewSpy(style: .doubleColumn)
        let sut = makeSUT(with: exploreSplitVCSpy)
        
        sut.start()
        let film = Film.sample[0]
        sut.didSelectFilm(film)
        
        #expect(exploreSplitVCSpy.hideWasCalled == true, "Should collapse the primary view controller.")
    }
    
    @Test("didSelectFilm pushes detail view controller to primary column for compact horizontal size class")
    func exploreSplitViewCoordinator_didSelectFilm_whenCollapsed_pushesExploreDetailVCToPrimaryColumn() {
        let exploreSplitVCSpy = CollapsedSplitViewSpy(style: .doubleColumn)
        let sut = makeSUT(with: exploreSplitVCSpy)
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader, filmSyncService: filmSyncService)
        let mockAccessibilityService = MockAccessibilityService()
        let mockExploreListVC = ExploreListVC(viewModel: filmsListViewModel, accessibilityService: mockAccessibilityService)
        let primaryNav = UINavigationController(rootViewController: mockExploreListVC)
        sut.exploreListVC = mockExploreListVC
        sut.exploreSplitVC.setViewController(primaryNav, for: .primary)
        
        primaryNav.traitOverrides.horizontalSizeClass = .compact
        let film = Film.sample[0]
        sut.didSelectFilm(film)
                
        let primaryVC = primaryNav.topViewController as! ExploreDetailVC
        #expect(primaryNav.topViewController is ExploreDetailVC, "The primary column should have `ExploreDetailVC` on top.")
        #expect(primaryVC.delegate === mockExploreListVC, "The detail view controller delegate must be set to the `ExploreListVC` instance.")
    }

    // MARK: - Helper Method
    private func makeSUT(with spy: UISplitViewController) -> ExploreSplitViewCoordinator {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        return ExploreSplitViewCoordinator(dependencies: MockContainer(),
                                           imageLoader: MockImageLoader(),
                                           filmQueueService: filmQueueService,
                                           filmSyncService: filmSyncService,
                                           exploreSplitVC: spy)
    }
    
    // MARK: - ExploreSplitVC Spies
    final class ExploreSplitVCSpy: UISplitViewController {
    }
    
    final class CollapsedSplitViewSpy: UISplitViewController {
        override var isCollapsed: Bool { return true }
    }

    final class ExpandedSplitViewSpy: UISplitViewController {
        var hideWasCalled = false
        override var isCollapsed: Bool { return false }
        
        override func hide(_ column: UISplitViewController.Column) {
            hideWasCalled = true
        }
    }
}
