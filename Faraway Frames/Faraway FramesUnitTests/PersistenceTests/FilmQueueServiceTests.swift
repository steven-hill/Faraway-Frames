//
//  FilmQueueServiceTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/06/2026.
//

import Testing
@testable import Faraway_Frames
import CoreData

@MainActor
struct FilmQueueServiceTests {

    @Test("Early exit returning false if trying to remove a film that doesn't exist in database")
    func filmQueueService_updateFilmStatus_existsEarlyIfFilmDoesNotExistInDatabase() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        let result = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .remove)
        
        #expect(result == false, "Should be false when trying to remove a film that doesn't exist in the database.")
    }
    
    @Test("Ensure that duplicates are not created in the database.")
    func filmQueueService_updateFilmStatus_checksFilmExistsInDatabaseBeforeCreatingANewOne() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        _ = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .add)
        
        _ = try await sut.updateFilmStatus(film: film, queue: .watched, action: .add)
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.predicate = NSPredicate(format: "id == %@", film.id)
        
        let existing = try testPersistenceController.viewContext.fetch(request).count
        
        #expect(existing == 1, "Should only be one film in the database.")
    }
    
    @Test("Can add a film to upNext")
    func filmQueueService_updateFilmStatus_addsAFilmToUpNext() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        let result = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .add)
        
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.predicate = NSPredicate(format: "id == %@", film.id)
        let existing = try testPersistenceController.viewContext.fetch(request)
        
        #expect(existing[0].isUpNext == true, "Should be true.")
        #expect(existing[0].id == film.id, "Should match.")
        #expect(result == true, "Should be true.")
    }
    
    @Test("Can remove a film from upNext")
    func filmQueueService_updateFilmStatus_removesAFilmFromUpNext() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        _ = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .add)
        _ = try await sut.updateFilmStatus(film: film, queue: .watched, action: .add)
        let result = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .remove)
        
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.predicate = NSPredicate(format: "id == %@", film.id)
        let existing = try testPersistenceController.viewContext.fetch(request)
        
        #expect(existing[0].isUpNext == false, "Should be false.")
        #expect(result == true, "Should be true.")
    }
    
    @Test("Can add a film to watched")
    func filmQueueService_updateFilmStatus_addsAFilmToWatched() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        let result = try await sut.updateFilmStatus(film: film, queue: .watched, action: .add)
        
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.predicate = NSPredicate(format: "id == %@", film.id)
        let existing = try testPersistenceController.viewContext.fetch(request)
        
        #expect(existing[0].isWatched == true, "Should be true.")
        #expect(existing[0].id == film.id, "Should match.")
        #expect(result == true, "Should be true.")
    }
    
    @Test("Can remove a film from watched")
    func filmQueueService_updateFilmStatus_removesAFilmFromWatched() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        _ = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .add)
        _ = try await sut.updateFilmStatus(film: film, queue: .watched, action: .add)
        let result = try await sut.updateFilmStatus(film: film, queue: .watched, action: .remove)
        
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.predicate = NSPredicate(format: "id == %@", film.id)
        let existing = try testPersistenceController.viewContext.fetch(request)
        
        #expect(existing[0].isWatched == false, "Should be false.")
        #expect(result == true, "Should be true.")
    }
    
    @Test("A film that is changed to false for both upNext and Watched should be deleted from database")
    func filmQueueService_updateFilmStatus_ifUpNextAndWatchedAreBothFalse_filmIsDeletedFromDatabase() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        _ = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .add)
        _ = try await sut.updateFilmStatus(film: film, queue: .watched, action: .add)
        
        let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        request.predicate = NSPredicate(format: "id == %@", film.id)
        var existing = try testPersistenceController.viewContext.fetch(request).count
        
        #expect(existing == 1, "Should be one film in database.")
        
        _ = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .remove)
        let result = try await sut.updateFilmStatus(film: film, queue: .watched, action: .remove)
        
        existing = try testPersistenceController.viewContext.fetch(request).count
        
        #expect(existing == 0, "Film should have been deleted from database.")
        #expect(result == true, "Should be true.")
    }
}
