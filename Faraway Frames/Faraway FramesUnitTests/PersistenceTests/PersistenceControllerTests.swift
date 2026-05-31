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
    
    @Test("Verify error is thrown when loading persistent stores fails")
    func persistenceController_whenLoadingPersistentStoresFails_throwsCorrectError() throws {
        let mockError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true) { container, completion in
                completion(NSPersistentStoreDescription(), mockError)
            }
        }
        
        #expect(thrownError == .loadingStoresFailed(error: mockError))
    }
    
    @Test("Verify Core Data stack can save films")
    func persistenceController_canSaveFilms() throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        let sampleFilm = Film.sample[0]
        _ = makeUpNextFilm(from: sampleFilm, entity: entity, context: context)
        
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
    
    @Test("Verify saving failed due to single nil attribute throws error")
    func persistenceController_whenSavingFailedDueToSingleNilAttribute_throwsError() throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        _ = makeUpNextFilmWithMissingIDAttribute(from: Film.sample[0], entity: entity, context: context)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try sut.saveContext()
        }
        switch thrownError {
        case .savingFailed(let error):
            let nsError = error as NSError
            #expect(nsError.domain == NSCocoaErrorDomain, "Should be Cocoa Error.")
            #expect(nsError.code == NSValidationMissingMandatoryPropertyError, "Should be `NSValidationMissingMandatoryPropertyError` because one attribute (.id) is nil.")
        default:
            Issue.record("Expected a .savingFailed error, but got \(thrownError)")
        }
    }
    
    @Test("Verify saving failed due to multiple nil attributes throws error")
    func persistenceController_whenSavingFailedDueToMultipleNilAttributes_throwsError() throws {
        let (sut, context, entity) = try makeSUTViewContextAndEntity()
        
        _ = makeUpNextFilmWithMultipleMissingAttributes(from: Film.sample[0], entity: entity, context: context)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try sut.saveContext()
        }
        switch thrownError {
        case .savingFailed(let error):
            let nsError = error as NSError
            #expect(nsError.domain == NSCocoaErrorDomain, "Should be Cocoa Error.")
            #expect(nsError.code == NSValidationMultipleErrorsError, "Should be `NSValidationMultipleErrorsError` because multiple attributes are nil.")
        default:
            Issue.record("Expected a .savingFailed error, but got \(thrownError)")
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
    
    private func makeUpNextFilm(from film: Film, entity: NSEntityDescription, context: NSManagedObjectContext) -> FilmMO {
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.id = film.id
        upNextFilm.title = film.title
        upNextFilm.originalTitle = film.originalTitle
        upNextFilm.originalTitleRomanised = film.originalTitleRomanised
        upNextFilm.image = film.image
        upNextFilm.movieBanner = film.movieBanner
        upNextFilm.filmDescription = film.description
        upNextFilm.director = film.director
        upNextFilm.producer = film.producer
        upNextFilm.releaseDate = film.releaseDate
        upNextFilm.runningTime = film.runningTime
        upNextFilm.rottenTomatoesScore = film.rottenTomatoesScore
        upNextFilm.url = film.url
        upNextFilm.isUpNext = true
        return upNextFilm
    }
    
    private func makeUpNextFilmWithMissingIDAttribute(from film: Film, entity: NSEntityDescription, context: NSManagedObjectContext) -> FilmMO {
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.title = film.title
        upNextFilm.originalTitle = film.originalTitle
        upNextFilm.originalTitleRomanised = film.originalTitleRomanised
        upNextFilm.image = film.image
        upNextFilm.movieBanner = film.movieBanner
        upNextFilm.filmDescription = film.description
        upNextFilm.director = film.director
        upNextFilm.producer = film.producer
        upNextFilm.releaseDate = film.releaseDate
        upNextFilm.runningTime = film.runningTime
        upNextFilm.rottenTomatoesScore = film.rottenTomatoesScore
        upNextFilm.url = film.url
        upNextFilm.isUpNext = true
        return upNextFilm
    }
    
    private func makeUpNextFilmWithMultipleMissingAttributes(from film: Film, entity: NSEntityDescription, context: NSManagedObjectContext) -> FilmMO {
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.title = film.title
        return upNextFilm
    }
}
