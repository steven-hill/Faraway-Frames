//
//  HomeVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 22/03/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct HomeVCTests {

    @Test func homeVC_canInitAndLoadView() {
        let sut = HomeVC()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
}
