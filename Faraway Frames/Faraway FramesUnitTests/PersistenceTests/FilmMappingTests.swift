//
//  FilmMappingTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 27/05/2026.
//

import Testing
import CoreData
@testable import Faraway_Frames

struct FilmMappingTests {
    
    @MainActor @Test("FilmMO maps to FilmWithStatus domain wrapper correctly")
    func filmMO_mapsToDomainWrapperCorrectly() throws {
        let container = try PersistenceController(inMemory: true)
        let context = container.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "FilmMO", in: context) else {
            let storeEntities = context.persistentStoreCoordinator?.managedObjectModel.entities.map { $0.name ?? "" } ?? []
            fatalError("Could not find entity `FilmMO` in model. Available entities: \(storeEntities)")
        }
        
        let managedObject = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        
        let domainWrapper = Film.from(
            id: managedObject.id,
            title: managedObject.title,
            originalTitle: managedObject.originalTitle,
            originalTitleRomanised: managedObject.originalTitleRomanised,
            image: managedObject.image,
            movieBanner: managedObject.movieBanner,
            filmDescription: managedObject.filmDescription,
            director: managedObject.director,
            producer: managedObject.producer,
            releaseDate: managedObject.releaseDate,
            runningTime: managedObject.runningTime,
            rottenTomatoesScore: managedObject.rottenTomatoesScore,
            url: managedObject.url,
            isUpNext: managedObject.isUpNext,
            isWatched: managedObject.isWatched)
        
        #expect(domainWrapper.id == Film.sample[0].id)
        #expect(domainWrapper.film.title == Film.sample[0].title)
        #expect(domainWrapper.film.director == Film.sample[0].director)
        #expect(domainWrapper.isUpNext == true)
        #expect(domainWrapper.isWatched == false)
    }
}
