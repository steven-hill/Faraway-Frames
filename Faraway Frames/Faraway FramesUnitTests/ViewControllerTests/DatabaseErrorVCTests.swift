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

    @Test("DatabaseErrorVC can be initialised and has a view")
    func databaseErrorVC_canInitAndLoadView() {
        let sut = DatabaseErrorVC(errorMessage: "Database errror")
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test("DatabaseErrorVC shows error configuration")
    func databaseErrorVC_whenThereIsAnError_updatesContentUnavailableConfiguration() {
        let sut = DatabaseErrorVC(errorMessage: "Database errror")
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
}
