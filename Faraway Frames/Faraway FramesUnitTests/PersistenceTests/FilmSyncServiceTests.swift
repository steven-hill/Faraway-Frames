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
    
    @Test("Should exit immediately if input films array is empty", (.tags(.persistence)))
    func filmSyncService_syncFilmsWithLocalStorage_ifFilmsArrayIsEmpty_exitsImmediately() async throws {
        let (sut, _, _) = try makeSUTViewContextAndEntity()
        let films: [Film] = []
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result.isEmpty, "Should be empty.")
    }
    
    @Test("If database is empty, should return the input films with their default flags unchanged", (.tags(.persistence)))
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseIsEmpty_returnsFilmsWithStatusUnchanged() async throws {
        let (sut, _, _) = try makeSUTViewContextAndEntity()
        let films = [Film.sample[0]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result == films, "Output should match input.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
    
    @Test("If database is not empty but records don't match the input, should return the input films with their default flags unchanged", (.tags(.persistence)))
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsDontMatchInput_returnsInputWithStatusUnchanged() async throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        try? context.save()
        let input = [Film.sample[1]]
        
        let result = await sut.syncFilmsWithLocalStorage(input)
        
        #expect(result == input, "Output should match input.")
        #expect(result[0].isUpNext == false, "Should be false (unchanged).")
        #expect(result[0].isWatched == false, "Should be false (unchanged).")
    }
    
    @Test("If database records match all the input, should update input films with the database state", (.tags(.persistence)))
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsAndInputMatchPerfectly_returnsInputWithStatusUpdated() async throws {
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
    
    @Test("If database records match some of the input, should only update the matching input films with the database state", (.tags(.persistence)))
    func filmSyncService_syncFilmsWithLocalStorage_ifDatabaseRecordsPartiallyMatchInput_updateOnlyThoseMatchingFilms() async throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        try? context.save()
        let films = [Film.sample[0], Film.sample[1]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result != films, "Output should not match input entirely.")
        #expect(result[0].isUpNext == true, "Should be updated to true.")
        #expect(result[0].isWatched == true, "Should be updated to true.")
        #expect(result[1].isUpNext == false, "Should be false (unchanged).")
        #expect(result[1].isWatched == false, "Should be false (unchanged).")
    }
    
    @Test("Return input films when database fetch fails", (.tags(.persistence)))
    func filmSyncService_syncFilmsWithLocalStorage_whenDatabaseFetchFails_returnsInputFilms() async throws {
        let mockContext = MockFailingDatabaseContext()
        let sut = FilmSyncService(context: mockContext)
        let films = [Film.sample[0], Film.sample[1]]
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result == films)
        #expect(result[0].id == Film.sample[0].id)
        #expect(result[0].isUpNext == false)
        #expect(result[0].isWatched == false)
        #expect(result[1].id == Film.sample[1].id)
        #expect(result[1].isUpNext == false)
        #expect(result[1].isWatched == false)
    }
    
    @Test("If database contains input film, should update input film with the database state", (.tags(.persistence)))
    func filmSyncService_syncSingleFilmWithLocalStorage_ifInputFilmIsFoundedInDatabase_returnsInputWithStatusUpdated() async throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: true)
        try? context.save()
        let film = Film.sample[0]
        
        let result = await sut.syncSingleFilmWithLocalStorage(film)
        
        #expect(result != film, "Output should not match input - should be updated.")
        #expect(result.isUpNext == true, "Should be updated to true.")
        #expect(result.isWatched == true, "Should be updated to true.")
    }
    
    @Test("If database doesn't contain input film, should return input film unaltered")
    func filmSyncService_syncSingleFilmWithLocalStorage_ifDatabaseDoesNotContainInputFilm_returnsInputFilmUnaltered() async throws {
        let (sut, _, _) = try makeSUTViewContextAndEntity()
        let film = Film.sample[0]
        
        let result = await sut.syncSingleFilmWithLocalStorage(film)
        
        #expect(result == film, "Output should match input.")
        #expect(result.isUpNext == false, "Should be unchanged.")
        #expect(result.isWatched == false, "Should be unchanged.")
    }
    
    @Test("If database fetch fails, fall back gracefully to the input film")
    func filmSyncService_syncSingleFilmWithLocalStorage_ifDatabaseThrowsFetchError_returnsInputFilmUnaltered() async throws {
        let mockContext = MockFailingDatabaseContext()
        let sut = FilmSyncService(context: mockContext)
        let film = Film.sample[0]
        
        let result = await sut.syncSingleFilmWithLocalStorage(film)
        
        #expect(result == film, "Output should match input.")
        #expect(result.isUpNext == false, "Should be unchanged.")
        #expect(result.isWatched == false, "Should be unchanged.")
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
    
    // MARK: - Mock Failing Database Context
    struct MockFailingDatabaseContext: DatabaseContext {
        func perform<T>(_ block: @escaping @Sendable () throws -> T) async rethrows -> T where T: Sendable {
            return try block()
        }
        
        nonisolated func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSManagedObject {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
    }
}
