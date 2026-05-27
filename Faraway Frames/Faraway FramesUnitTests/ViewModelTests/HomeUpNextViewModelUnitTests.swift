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
        let sut = HomeUpNextViewModel()
        
        #expect(sut.currentState == .noFilms, "Should be `.noFilms` on init.")
    }

    @Test func homeUpNextViewModel_onInit_hasNoFilms() {
        let sut = HomeUpNextViewModel()
        
        #expect(sut.upNextFilms.isEmpty, "Should be empty.")
    }
    
    @Test("Verify `HomeUpNextViewModel` fetches and filters only Up Next records")
    func homeUpNextViewModel_fetchesAndFiltersCorrectly() throws {
        let container = FakeCoreDataStack.makeInMemoryContainer()
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FilmMO", in: context)!
        
        let upNextFilm = FilmMO(entity: entity, insertInto: context)
        upNextFilm.id = Film.sample[0].id
        upNextFilm.title = Film.sample[0].title
        upNextFilm.isUpNext = true
        upNextFilm.isWatched = false
        
        let watchedFilm = FilmMO(entity: entity, insertInto: context)
        watchedFilm.id = Film.sample[1].id
        watchedFilm.title = Film.sample[1].title
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
        
        func upNextFilmsDidUpdate(films: [FilmWithStatus]) {
            self.updatedFilms = films
            self.callCount += 1
        }
    }
}
