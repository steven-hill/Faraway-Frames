//
//  FilmSyncServiceTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 19/06/2026.
//

import Testing
@testable import Faraway_Frames

@MainActor
struct FilmSyncServiceTests {

    @Test("Should exit immediately if input films array is empty")
    func filmSyncService_syncFilmsWithLocalStorage_ifFilmsArrayIsEmpty_exitsImmediately() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmSyncService(context: testPersistenceController.viewContext)
        let films: [Film] = []
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result.isEmpty, "Should be empty.")
    }

    @Test("If database contains no matching records, should return the original remote films with their default flags unchanged.")
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsDontMatchFilms_returnsFilmsWithStatusUnchanged() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmSyncService(context: testPersistenceController.viewContext)
        let films = [Film.sample[0]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result == films, "Should match.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
}
