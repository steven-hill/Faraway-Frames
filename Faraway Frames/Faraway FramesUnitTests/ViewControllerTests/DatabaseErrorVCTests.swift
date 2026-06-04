//
//  DatabaseErrorVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 04/06/2026.
//

import Testing
import UIKit
@testable import Faraway_Frames

@MainActor
struct DatabaseErrorVCTests {

    @Test func databaseErrorVC_canInitAndLoadView() {
        let sut = DatabaseErrorVC()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
}
