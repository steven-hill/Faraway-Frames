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
        let sut = makeSUT()
        
        let result = sut.splitViewController(sut.exploreSplitVC, topColumnForCollapsingToProposedTopColumn: .primary)
        
        #expect(result == .primary, "Should display the primary column after the split view interface collapses.")
    }
    
    // MARK: - Helper Method
    private func makeSUT() -> ExploreSplitViewCoordinator {
        let exploreSplitVCSpy = ExploreSplitVCSpy()
        return ExploreSplitViewCoordinator(dependencies: MockContainer(), exploreSplitVC: exploreSplitVCSpy)
    }
    
    // MARK: - ExploreSplitVC Spy
    final class ExploreSplitVCSpy: UISplitViewController {
    }
}
