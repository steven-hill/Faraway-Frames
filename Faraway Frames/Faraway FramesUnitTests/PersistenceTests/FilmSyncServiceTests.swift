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
    func filmSyncService_syncFilmsWithLocalStorage_ifFilmsArrayIsEmpty_exitsImmediately() async throws {
        let (sut, _, _) = try makeSUTViewContextAndEntity()
        let films: [Film] = []
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result.isEmpty, "Should be empty.")
    }

    @Test("If database is empty, should return the input films with their default flags unchanged.")
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseIsEmpty_returnsFilmsWithStatusUnchanged() async throws {
        let (sut, _, _) = try makeSUTViewContextAndEntity()
        let films = [Film.sample[0]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result == films, "Output should match input.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
    
    @Test("If database is not empty but records don't match the input, should return the input films with their default flags unchanged.")
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsDontMatchInput_returnsInputWithStatusUnchanged() async throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        try? context.save()
        let filmB = [Film.sample[1]]
        
        let result = await sut.syncFilmsWithLocalStorage(filmB)
        
        #expect(result == filmB, "Output should match input.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
    
    @Test("If database records match the input, should update films matching database state.")
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsAndInputMatch_returnsInputWithStatusUpdated() async throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[1], entity: entity, context: context, isUpNext: true, isWatched: true)
        try? context.save()
        let films = [Film.sample[0], Film.sample[1]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result != films, "Output should not match input.")
        #expect(result[0].isUpNext == true, "Should be updated to true.")
        #expect(result[0].isWatched == true, "Should be updated to true.")
        #expect(result[1].isUpNext == true, "Should be updated to true.")
        #expect(result[1].isWatched == true, "Should be updated to true.")
    }
    
    // MARK: - SUT Helper Method
    private func makeSUTViewContextAndEntity() throws -> (sut: FilmSyncService,
                                                          viewContext: NSManagedObjectContext,
                                                          entity: NSEntityDescription) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let sut = FilmSyncService(context: context)
        return (sut, context, entity)
    }
}
