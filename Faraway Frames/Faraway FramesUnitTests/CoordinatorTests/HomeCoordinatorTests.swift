//
//  HomeCoordinatorTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 22/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct HomeCoordinatorTests {
    
    @Test func homeCoordinator_start_setsUpHomeVCWithNavController() {
        let sut = HomeCoordinator()
        
        sut.start()
        
        #expect(sut.homeVC.navigationController != nil, "Should not be nil.")
    }
}
