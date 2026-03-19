//
//  AssistantCoordinatorTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 19/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct AssistantCoordinatorTests {

    @Test func assistantCoordinator_start_setsUpAssistantVCWithNavController() {
        let sut = AssistantCoordinator()
        
        sut.start()
        
        #expect(sut.assistantVC.navigationController != nil, "Should not be nil.")
    }
}
