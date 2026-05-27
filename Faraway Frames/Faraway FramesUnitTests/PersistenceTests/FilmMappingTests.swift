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
    
    @MainActor @Test("Verify FilmMO maps to FilmWithStatus domain wrapper correctly")
    func filmMO_mapsToDomainWrapperCorrectly() throws {
        let container = FakeCoreDataStack.makeInMemoryContainer()
        let context = container.viewContext
        
        let managedObject = FilmMO(context: context)
        managedObject.id = Film.sample[0].id
        managedObject.title = Film.sample[0].title
        managedObject.originalTitle = Film.sample[0].originalTitle
        managedObject.originalTitleRomanised = Film.sample[0].originalTitleRomanised
        managedObject.image = Film.sample[0].image
        managedObject.movieBanner = Film.sample[0].movieBanner
        managedObject.filmDescription = Film.sample[0].description
        managedObject.director = Film.sample[0].director
        managedObject.producer = Film.sample[0].producer
        managedObject.releaseDate = Film.sample[0].releaseDate
        managedObject.runningTime = Film.sample[0].runningTime
        managedObject.rottenTomatoesScore = Film.sample[0].rottenTomatoesScore
        managedObject.url = Film.sample[0].url
        managedObject.isUpNext = true
        managedObject.isWatched = false
        
        let domainWrapper: FilmWithStatus = managedObject.toDomain()
        
        #expect(domainWrapper.id == Film.sample[0].id)
        #expect(domainWrapper.film.title == Film.sample[0].title)
        #expect(domainWrapper.film.director == Film.sample[0].director)
        #expect(domainWrapper.isUpNext == true)
        #expect(domainWrapper.isWatched == false)
    }
}

