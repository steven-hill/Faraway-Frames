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
    
    @Test("UpNext fetch request returns the correct filtering configurations", (.tags(.persistence)))
    func filmMO_upNextFetchRequest_hasCorrectPredicateAndSort() {
        let request = FilmMO.upNextFetchRequest()
        
        #expect(request.entityName == Persistence.entityname, "Should target the FilmMO table.")
        #expect(request.sortDescriptors?.first?.key == "dateAddedToUpNext", "Should sort rows by date added.")
        #expect(request.predicate?.predicateFormat == "isUpNext == 1", "Predicate must filter strictly for active true status.")
    }
    
    @Test("Watched fetch request returns the correct filtering configurations", (.tags(.persistence)))
    func filmMO_watchedFetchRequest_hasCorrectPredicateAndSort() {
        let request = FilmMO.watchedFetchRequest()
        
        #expect(request.entityName == Persistence.entityname, "Should target the FilmMO table.")
        #expect(request.sortDescriptors?.first?.key == "dateAddedToWatched", "Should sort rows by date added.")
        #expect(request.predicate?.predicateFormat == "isWatched == 1", "Predicate must filter strictly for active true status.")
    }
    
    @Test("Explore Detail fetch request returns the correct filtering configurations", (.tags(.persistence)))
    func filmMO_exploreDetailFetchRequest_hasCorrectPredicateAndSort() {
        let request = FilmMO.exploreDetailFetchRequest(using: "test_id")
        
        #expect(request.entityName == Persistence.entityname, "Should target the FilmMO table.")
        #expect(request.sortDescriptors?.first?.key == "title", "Should sort rows by their title.")
        #expect(request.predicate?.predicateFormat == "id == \"test_id\"", "Predicate must filter strictly for `film.id`.")
    }
}
