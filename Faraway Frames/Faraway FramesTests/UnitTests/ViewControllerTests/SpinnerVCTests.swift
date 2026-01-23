//
//  SpinnerVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 23/01/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct SpinnerVCTests {
    
    @Test func spinner_isAddedToHierarchy() {
        let sut = SpinnerVC()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.spinner.isDescendant(of: sut.view), "Spinner should be added to the view hierarchy.")
    }
    
    @Test func spinner_startsAnimating_onLoad() {
        let sut = SpinnerVC()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.spinner.isAnimating == true, "Spinner should start animating on loading the view.")
    }
}
