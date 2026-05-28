//
//  PersistenceControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 28/05/2026.
//

import Testing
import CoreData
@testable import Faraway_Frames

struct PersistenceControllerTests {
    
    @Test("Verify error thrown when loading persistent stores fails")
    func persistenceController_whenLoadingPersistentStoresFails_throwsCorrectError() throws {
        let mockError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true) { container, completion in
                completion(NSPersistentStoreDescription(), mockError)
            }
        }
        
        #expect(thrownError == .loadingStoresFailed(error: mockError))
    }
    
    @MainActor @Test("Verify Core Data stack can save and fetch films")
    func persistenceController_canFetchSavedFilms() throws {
        let sut = try PersistenceController(inMemory: true)
        let context = sut.viewContext
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        
        let sampleFilm = Film.sample[0]
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.id = sampleFilm.id
        upNextFilm.title = sampleFilm.title
        upNextFilm.originalTitle = sampleFilm.originalTitle
        upNextFilm.originalTitleRomanised = sampleFilm.originalTitleRomanised
        upNextFilm.image = sampleFilm.image
        upNextFilm.movieBanner = sampleFilm.movieBanner
        upNextFilm.filmDescription = sampleFilm.description
        upNextFilm.director = sampleFilm.director
        upNextFilm.producer = sampleFilm.producer
        upNextFilm.releaseDate = sampleFilm.releaseDate
        upNextFilm.runningTime = sampleFilm.runningTime
        upNextFilm.rottenTomatoesScore = sampleFilm.rottenTomatoesScore
        upNextFilm.url = sampleFilm.url
        upNextFilm.isUpNext = true
        
        #expect(throws: Never.self) { try sut.saveContext() }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FilmMO")
        fetchRequest.predicate = NSPredicate(format: "isUpNext == YES")
        
        let rawResults = try context.fetch(fetchRequest)
        #expect(rawResults.count == 1, "The database should contain exactly one saved record.")
        
        if let retrievedFilm = rawResults.first as? NSManagedObject {
            let titleValue = retrievedFilm.value(forKey: "title") as? String
            #expect(titleValue == sampleFilm.title, "The retrieved title should match the sample data.")
            
            let isUpNextValue = retrievedFilm.value(forKey: "isUpNext") as? Bool
            #expect(isUpNextValue == true, "The tracking state flag should remain intact.")
        }
    }
}

