//
//  PersistenceControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 28/05/2026.
//

import Testing
import CoreData
@testable import Faraway_Frames

@MainActor
struct PersistenceControllerTests {
    
    @Test("Invalid persistent container name string throws a loading failure")
    func persistenceController_withTypoInContainerName_throwsLoadingStoresFailedError() throws {
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true, containerName: "FarawayFramesCDModelTypo")
        }
        
        switch thrownError {
        case .loadingStoresFailed(let error):
            let nsError = error as NSError
            #expect(nsError.domain == NSCocoaErrorDomain, "Should be a Cocoa error")
            #expect(nsError.code == NSFileReadNoSuchFileError, "Should be a no such file error")
        default:
            Issue.record("Expected .loadingStoresFailed, but got \(thrownError)")
        }
    }
    
    @Test("Error is thrown when loading persistent stores fails")
    func persistenceController_whenLoadingPersistentStoresFails_throwsCorrectError() throws {
        let mockError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true) { container, completion in
                completion(NSPersistentStoreDescription(), mockError)
            }
        }
        
        #expect(thrownError == .loadingStoresFailed(error: mockError))
    }
    
    @Test("Core Data stack can save films")
    func persistenceController_canSaveFilms() throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        let sampleFilm = Film.sample[0]
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        
        #expect(throws: Never.self) { try sut.saveContext() }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FilmMO")
        fetchRequest.predicate = NSPredicate(format: "isUpNext == YES")
        
        let rawResults = try context.fetch(fetchRequest)
        #expect(rawResults.count == 1, "Should contain exactly one film.")
        
        if let retrievedFilm = rawResults.first as? NSManagedObject {
            let titleValue = retrievedFilm.value(forKey: "title") as? String
            #expect(titleValue == sampleFilm.title, "The fetched title should match the sample film's title.")
            
            let isUpNextValue = retrievedFilm.value(forKey: "isUpNext") as? Bool
            #expect(isUpNextValue == true, "Should be true.")
        }
    }
    
    @Test("Saving succeeds even if some attributes are nil")
    func persistenceController_whenSavingWithNilAttributes_succeedsWithoutError() throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        
        _ = makeUpNextFilmWithMultipleMissingAttributes(from: Film.sample[0], entity: entity, context: context)
        
        #expect(throws: Never.self, "Should not throw an error") {
            try sut.saveContext()
        }
    }
    
    // MARK: - Helper methods
    private func makeSUTViewContextAndEntity() throws -> (sut: PersistenceController, viewContext: NSManagedObjectContext, entity: NSEntityDescription) {
        let sut = try PersistenceController.init(inMemory: true)
        let viewContext = sut.viewContext
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: viewContext),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        return (sut, viewContext, entity)
    }
    
    private func makeUpNextFilmWithMultipleMissingAttributes(from film: Film, entity: NSEntityDescription, context: NSManagedObjectContext) -> FilmMO {
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.title = film.title
        return upNextFilm
    }
}
