//
//  HomeViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 06/06/2026.
//

import Testing
@testable import Faraway_Frames
import CoreData

@MainActor
struct HomeViewModelTests {
    
    @Test("`currentState` is correct on init")
    func homeViewModel_currentStateOnInit_isIdle() throws {
        let persistenceController = try PersistenceController(inMemory: true)
        let sut = HomeViewModel(persistentContainer: persistenceController.container)
        
        #expect(sut.currentState == .idle, "Should be `.idle`.")
    }
    
    @Test("`currentState` is correct after fetching Up Next films and Watched films")
    func homeViewModel_currentStateAfterFetches_isFetchedObjects() throws {
        let persistenceController = try PersistenceController(inMemory: true)
        let sut = HomeViewModel(persistentContainer: persistenceController.container)
        
        sut.performFetches()
        
        #expect(sut.currentState == .fetchedObjects, "Should be `.fetchedObjects`.")
    }
    
    @Test("`HomeViewModel` can fetch up next films and watched films")
    func homeUpNextViewModel_performFetches_fetchesCorrectly() throws {
        let persistenceController = try PersistenceController(inMemory: true)
        let sut = HomeViewModel(persistentContainer: persistenceController.container)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let context = persistenceController.viewContext
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[1], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        
        sut.performFetches()
        
        #expect(delegateSpy.callCount == 1, "Should make the call once.")
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.count == 1, "Should be one.")
        let filmUpNext = try #require(upNextFilms.first, "The film array should contain a film.")
        #expect(filmUpNext.id == Film.sample[0].id, "Should be equal.")
        #expect(filmUpNext.film.title == Film.sample[0].title, "Should be equal.")
        
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(watchedFilms.count == 1, "Should be one.")
        let filmWatched = try #require(watchedFilms.first, "The film array should contain a film.")
        #expect(filmWatched.id == Film.sample[1].id, "Should be equal.")
        #expect(filmWatched.film.title == Film.sample[1].title, "Should be equal.")
    }
    
    //MARK: - Home ViewModel Delegate Spy
    final class HomeViewModelDelegateSpy: HomeViewModelDelegate {
        var upNextFilms: [FilmWithStatus]?
        var watchedFilms: [FilmWithStatus]?
        var callCount: Int = 0
        
        func filmsDidChange(_ upNextFilms: [Faraway_Frames.FilmWithStatus], _ watchedFilms: [Faraway_Frames.FilmWithStatus]) {
            self.upNextFilms = upNextFilms
            self.watchedFilms = watchedFilms
            self.callCount += 1
        }
    }
}
