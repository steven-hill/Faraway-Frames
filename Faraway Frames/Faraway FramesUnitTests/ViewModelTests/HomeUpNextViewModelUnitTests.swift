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
    
    @Test func homeUpNextViewModel_currentStateOnInit_isNoFilms() throws {
        let persistenceController = try PersistenceController(inMemory: true)
        let sut = HomeUpNextViewModel(persistentContainer: persistenceController.container)
        
        #expect(sut.currentState == .noFilms, "Should be `.noFilms` on init.")
    }
    
    @Test("Verify `HomeUpNextViewModel` only fetches Up Next records")
    func homeUpNextViewModel_fetchesCorrectly() throws {
        let persistenceController = try PersistenceController(inMemory: true)
        let sut = HomeUpNextViewModel(persistentContainer: persistenceController.container)
        let delegateSpy = HomeUpNextViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let context = persistenceController.viewContext
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[1], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        
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
