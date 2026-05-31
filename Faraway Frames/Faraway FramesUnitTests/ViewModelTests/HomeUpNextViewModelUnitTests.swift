//
//  HomeUpNextViewModelUnitTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 26/03/2026.
//

import Testing
@testable import Faraway_Frames
import CoreData

@MainActor
struct HomeUpNextViewModelUnitTests {
    
    @Test func homeUpNextViewModel_currentStateOnInit_isNoFilms() {
        let container = FakeCoreDataStack.makeInMemoryContainer()
        let sut = HomeUpNextViewModel(persistentContainer: container)
        
        #expect(sut.currentState == .noFilms, "Should be `.noFilms` on init.")
    }
    
    @Test("Verify `HomeUpNextViewModel` fetches only Up Next records")
    func homeUpNextViewModel_fetchesCorrectly() throws {
        let container = FakeCoreDataStack.makeInMemoryContainer()
        let context = container.viewContext
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.id = Film.sample[0].id
        upNextFilm.title = Film.sample[0].title
        upNextFilm.originalTitle = Film.sample[0].originalTitle
        upNextFilm.originalTitleRomanised = Film.sample[0].originalTitleRomanised
        upNextFilm.image = Film.sample[0].image
        upNextFilm.movieBanner = Film.sample[0].movieBanner
        upNextFilm.filmDescription = Film.sample[0].description
        upNextFilm.director = Film.sample[0].director
        upNextFilm.producer = Film.sample[0].producer
        upNextFilm.releaseDate = Film.sample[0].releaseDate
        upNextFilm.runningTime = Film.sample[0].runningTime
        upNextFilm.rottenTomatoesScore = Film.sample[0].rottenTomatoesScore
        upNextFilm.url = Film.sample[0].url
        upNextFilm.isUpNext = true
        upNextFilm.isWatched = false
        
        let watchedFilm = FilmMO(entity: entity, insertInto: context)
        watchedFilm.id = Film.sample[1].id
        watchedFilm.title = Film.sample[1].title
        watchedFilm.originalTitle = Film.sample[1].originalTitle
        watchedFilm.originalTitleRomanised = Film.sample[1].originalTitleRomanised
        watchedFilm.image = Film.sample[1].image
        watchedFilm.movieBanner = Film.sample[1].movieBanner
        watchedFilm.filmDescription = Film.sample[1].description
        watchedFilm.director = Film.sample[1].director
        watchedFilm.producer = Film.sample[1].producer
        watchedFilm.releaseDate = Film.sample[1].releaseDate
        watchedFilm.runningTime = Film.sample[1].runningTime
        watchedFilm.rottenTomatoesScore = Film.sample[1].rottenTomatoesScore
        watchedFilm.url = Film.sample[1].url
        watchedFilm.isUpNext = false
        watchedFilm.isWatched = true
        
        try context.save()
        
        let sut = HomeUpNextViewModel(persistentContainer: container)
        let delegateSpy = HomeUpNextViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startFetching()
        
        #expect(delegateSpy.callCount == 1, "Should make the call once.")
        let films = try #require(delegateSpy.updatedFilms, "Delegate should have received a films array.")
        #expect(films.count == 1, "Should be one.")
        let firstFilm = try #require(films.first, "The film array should contain a film.")
        #expect(firstFilm.id == Film.sample[0].id, "Should be equal.")
        #expect(firstFilm.film.title == Film.sample[0].title, "Should be equal.")
    }
    
    //MARK: - Home UpNext ViewModel Delegate Spy
    final class HomeUpNextViewModelDelegateSpy: HomeUpNextViewModelDelegate {
        var updatedFilms: [FilmWithStatus]?
        var callCount: Int = 0
        
        func upNextFilmsDidChange(_ films: [FilmWithStatus]) {
            self.updatedFilms = films
            self.callCount += 1
        }
    }
}
