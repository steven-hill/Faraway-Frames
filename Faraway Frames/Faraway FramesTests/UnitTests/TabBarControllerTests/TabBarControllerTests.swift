//
//  TabBarControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 06/01/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct TabBarControllerTests {
    
    @Test func tabBarController_viewDidLoad_setsModeCorrectly() {
        let sut = TabBarController()
        sut.loadViewIfNeeded()
        #expect(sut.mode == .tabSidebar, "Should be `.tabSidebar`.")
    }
}

