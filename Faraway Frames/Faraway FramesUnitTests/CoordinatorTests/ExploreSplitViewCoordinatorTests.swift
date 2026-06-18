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
    
    @Test func exploreSplitViewCoordinator_onInit_setsDelegateCorrectly() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(), filmQueueService: filmQueueService, exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        #expect(sut.exploreSplitVC.delegate != nil, "Should not be nil.")
    }
    
    @Test func exploreSplitViewCoordinator_setsUpPrimaryVCCorrectly() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(), filmQueueService: filmQueueService, exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        let primary = exploreSplitVCSpy.viewController(for: .primary)
        #expect(primary is UINavigationController)
        #expect((primary as? UINavigationController)?.topViewController is ExploreListVC)
    }
    
    @Test func exploreSplitViewCoordinator_setsUpSecondaryVCCorrectly() {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(), filmQueueService: filmQueueService, exploreSplitVC: exploreSplitVCSpy)
        
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
    
    @Test func exploreSplitViewCoordinator_didSelectFilm_withFilm_createsExploreDetailVC() {
        let sut = makeSUT(with: ExploreSplitVCSpy(style: .doubleColumn))
        
        sut.start()
        let film = Film.sample[0]
        sut.didSelectFilm(film)
        
        #expect(sut.exploreSplitVC.viewControllers.count == 2, "Should be 2.")
        #expect(sut.exploreSplitVC.viewControllers[1] is ExploreDetailVC, "Should be an `ExploreDetailVC`.")
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
    
    // MARK: - Helper Method
    private func makeSUT(with spy: UISplitViewController) -> ExploreSplitViewCoordinator {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        return ExploreSplitViewCoordinator(dependencies: MockContainer(), filmQueueService: filmQueueService, exploreSplitVC: spy)
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
