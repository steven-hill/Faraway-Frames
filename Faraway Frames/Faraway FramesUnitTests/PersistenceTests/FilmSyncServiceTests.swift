//
//  FilmSyncServiceTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 19/06/2026.
//

import Testing
@testable import Faraway_Frames
import CoreData

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

    @Test("If database is empty, should return the input films with their default flags unchanged.")
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseIsEmpty_returnsFilmsWithStatusUnchanged() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmSyncService(context: testPersistenceController.viewContext)
        let films = [Film.sample[0]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result == films, "Output should match input.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
    
    @Test("If database is not empty but records don't match the input, should return the input films with their default flags unchanged.")
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsDontMatchInput_returnsInputWithStatusUnchanged() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let sut = FilmSyncService(context: context)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        try? context.save()
        let filmB = [Film.sample[1]]
        
        let result = await sut.syncFilmsWithLocalStorage(filmB)
        
        #expect(result == filmB, "Output should match input.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
}
