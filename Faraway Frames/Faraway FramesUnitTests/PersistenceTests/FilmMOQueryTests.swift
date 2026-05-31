//
//  FilmMOQueryTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 31/05/2026.
//

import Testing

struct FilmMOQueryTests {
    
    @Test("Verify upNext FetchRequest returns the correct filtering configurations")
    func filmMO_upNextFetchRequest_hasCorrectPredicateAndSort() {
        let request = FilmMO.upNextFetchRequest()
        
        #expect(request.entityName == "FilmMO", "Should target the FilmMO table.")
        #expect(request.sortDescriptors?.first?.key == "title", "Should sort rows by their title.")
        #expect(request.predicate?.predicateFormat == "isUpNext == YES", "Predicate must filter strictly for active true status.")
    }
}
