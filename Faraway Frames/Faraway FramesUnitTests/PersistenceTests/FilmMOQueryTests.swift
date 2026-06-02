//
//  FilmMOQueryTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 31/05/2026.
//

import Testing
@testable import Faraway_Frames
import CoreData

struct FilmMOQueryTests {
    
    @Test("Verify upNext fetch request returns the correct filtering configurations")
    func filmMO_upNextFetchRequest_hasCorrectPredicateAndSort() {
        let request = FilmMO.upNextFetchRequest()
        
        #expect(request.entityName == "FilmMO", "Should target the FilmMO table.")
        #expect(request.sortDescriptors?.first?.key == "title", "Should sort rows by their title.")
        #expect(request.predicate?.predicateFormat == "isUpNext == 1", "Predicate must filter strictly for active true status.")
    }
    
    @Test("Verify watched fetch request returns the correct filtering configurations")
    func filmMO_watchedFetchRequest_hasCorrectPredicateAndSort() {
        let request = FilmMO.watchedFetchRequest()
        
        #expect(request.entityName == "FilmMO", "Should target the FilmMO table.")
        #expect(request.sortDescriptors?.first?.key == "title", "Should sort rows by their title.")
        #expect(request.predicate?.predicateFormat == "isWatched == 1", "Predicate must filter strictly for active true status.")
    }
}
