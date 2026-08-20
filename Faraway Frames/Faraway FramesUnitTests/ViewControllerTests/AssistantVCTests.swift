//
//  AssistantVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 19/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct AssistantVCTests {

    @Test func assistantVC_canInitAndLoadView() {
        let assistantVC = AssistantViewModel(foundationModelsClient: MockFoundationModelsClient())
        let sut = AssistantVC(assistantViewModel: assistantVC)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
}
