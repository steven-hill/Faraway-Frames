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
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test("DatabaseErrorVC shows error configuration")
    func databaseErrorVC_whenThereIsAnError_updatesContentUnavailableConfiguration() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    //MARK: - Helper method
    private func makeSUT() -> DatabaseErrorVC {
        DatabaseErrorVC(errorMessage: "Database error")
    }
}
