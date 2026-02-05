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
    
    @Test func exploreSplitViewCoordinator_setsDelegateCorrectly_onInit() {
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(), exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        #expect(sut.exploreSplitVC.delegate != nil, "Should not be nil.")
    }
    
    @Test func exploreSplitViewCoordinator_setsUpPrimaryVCCorrectly() {
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(), exploreSplitVC: exploreSplitVCSpy)
        
        sut.start()
        
        let primary = exploreSplitVCSpy.viewController(for: .primary)
        #expect(primary is UINavigationController)
        #expect((primary as? UINavigationController)?.topViewController is ExploreListVC)
    }
    
    @Test func exploreSplitViewCoordinator_setsUpSecondaryVCCorrectly() {
        let exploreSplitVCSpy = ExploreSplitVCSpy(style: .doubleColumn)
        let sut = ExploreSplitViewCoordinator(dependencies: MockContainer(), exploreSplitVC: exploreSplitVCSpy)
        
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
    
    @Test func exploreSplitViewCoordinator_shouldDeselect_onIphone() {
        let exploreSplitVCSpy = CollapsedSplitViewSpy()
        let sut = makeSUT(with: exploreSplitVCSpy)

        #expect(sut.shouldDeselectAfterSelection == true, "Should be true.")
    }
    
    @Test func exploreSplitViewCoordinator_shouldKeepSelection_onIpad() {
        let exploreSplitVCSpy = ExpandedSplitViewSpy()
        let sut = makeSUT(with: exploreSplitVCSpy)

        #expect(sut.shouldDeselectAfterSelection == false, "Should be false.")
    }
    
    // MARK: - Helper Method
    private func makeSUT(with spy: UISplitViewController) -> ExploreSplitViewCoordinator {
        return ExploreSplitViewCoordinator(dependencies: MockContainer(), exploreSplitVC: spy)
    }
    
    // MARK: - ExploreSplitVC Spies
    final class ExploreSplitVCSpy: UISplitViewController {
    }
    
    final class CollapsedSplitViewSpy: UISplitViewController {
        override var isCollapsed: Bool { return true }
    }

    final class ExpandedSplitViewSpy: UISplitViewController {
        override var isCollapsed: Bool { return false }
    }
}
