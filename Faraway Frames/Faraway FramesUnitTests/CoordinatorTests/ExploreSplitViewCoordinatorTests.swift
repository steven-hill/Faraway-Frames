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
        let (sut, _) = makeSUT()
        
        sut.start()
        
        #expect(sut.exploreSplitVC.delegate != nil, "Should not be nil.")
    }
    
    @Test func exploreSplitViewCoordinator_setsUpPrimaryVCCorrectly() {
        let (sut, exploreSplitVCSpy) = makeSUT()
        
        sut.start()
        
        let primary = exploreSplitVCSpy.viewController(for: .primary)
        #expect(primary is UINavigationController, "Should be a navigation controller.")
        #expect((primary as? UINavigationController)?.topViewController is ExploreListVC, "Should be `ExploreListVC`.")
    }
    
    @Test func exploreSplitViewCoordinator_setsUpSecondaryVCCorrectly() {
        let (sut, exploreSplitVCSpy) = makeSUT()
        
        sut.start()
        
        let secondary = exploreSplitVCSpy.viewController(for: .secondary)
        #expect(secondary is UINavigationController, "Should be a navigation controller.")
        #expect((secondary as? UINavigationController)?.topViewController is ExploreDetailVC, "Should be `ExploreDetailVC`.")
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
    
    @Test("Two view controllers are created, and delegate is set")
    func exploreSplitViewCoordinator_didSelectFilm_withFilm_createsExploreDetailVCAndSetsItsDelegate() {
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
        
        #expect(detailVC.delegate === expectedListVC, "The detail view controller delegate must be set to the `ExploreListVC` instance.")
    }
    
    @Test("iPad only: Primary VC's column is collapsed when film is selected from list", .enabled(if: IpadHelper.isPad))
    func exploreSplitViewCoordinator_didSelectFilm_withFilm_collapsesPrimaryViewControllerColumn() {
        let exploreSplitVCSpy = ExpandedSplitViewSpy(style: .doubleColumn)
        let sut = makeSUT(with: exploreSplitVCSpy)
        
        sut.start()
        let film = Film.sample[0]
        sut.didSelectFilm(film)
        
        #expect(exploreSplitVCSpy.hideWasCalled == true, "Should collapse the primary view controller's column.")
    }
    
    @Test("Presents VC modally when the user taps the `More Like This` button")
    func exploreSplitViewCoordinator_didTapMoreLikeThisButton_presentsVCModally() {
        let spy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = makeSUT(with: spy)
        sut.start()
        
        sut.exploreDetailDidTapMoreLikeThisButton()
        
        #expect(spy.didPresentModal, "Should have presented a VC modally.")
    }

    // MARK: - SUT Helper Methods
    private func makeSUT() -> (sut: ExploreSplitViewCoordinator, exploreSplitVCSpy: UISplitViewController) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(),
                                              imageLoader: MockImageLoader(),
                                              context: testPersistenceController.viewContext,
                                              filmQueueService: filmQueueService,
                                              filmSyncService: filmSyncService,
                                              exploreSplitVC: exploreSplitVCSpy,
                                              frcFactory: MockFRCFactory())
        return (sut, exploreSplitVCSpy)
    }
    
    private func makeSUT(with spy: UISplitViewController) -> ExploreSplitViewCoordinator {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        return ExploreSplitViewCoordinator(dependencies: MockContainer(),
                                           imageLoader: MockImageLoader(),
                                           context: testPersistenceController.viewContext,
                                           filmQueueService: filmQueueService,
                                           filmSyncService: filmSyncService,
                                           exploreSplitVC: spy,
                                           frcFactory: MockFRCFactory())
    }
    
    // MARK: - ExploreSplitVC Spies
    final class ExploreSplitVCSpy: UISplitViewController {
        var didPresentModal = false
        
        override func present(_ viewControllerToPresent: UIViewController,
                              animated flag: Bool,
                              completion: (() -> Void)? = nil) {
            didPresentModal = true
        }
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
