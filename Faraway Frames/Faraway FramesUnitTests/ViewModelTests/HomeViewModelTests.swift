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
    func homeViewModel_currentStateOnInit_isIdle() {
        let (sut,_) = makeSUTWithContext()
        
        #expect(sut.currentState == .idle, "Should be `.idle`.")
    }
    
    @Test("`currentState` is correct after fetching Up Next films and Watched films")
    func homeViewModel_currentStateAfterFetches_isFetchedObjects() {
        let (sut,_) = makeSUTWithContext()
        
        sut.performFetches()
        
        #expect(sut.currentState == .fetchedObjects, "Should be `.fetchedObjects`.")
    }
    
    @Test("`HomeViewModel` can fetch up next films and watched films, and calls delegate")
    func homeViewModel_performFetches_fetchesCorrectly() throws {
        let (sut, context) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[1], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.count == 1, "Should be one.")
        let filmUpNext = try #require(upNextFilms.first, "The film array should contain a film.")
        #expect(filmUpNext.id == Film.sample[0].id, "Should be equal.")
        #expect(filmUpNext.title == Film.sample[0].title, "Should be equal.")
        
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(watchedFilms.count == 1, "Should be one.")
        let filmWatched = try #require(watchedFilms.first, "The film array should contain a film.")
        #expect(filmWatched.id == Film.sample[1].id, "Should be equal.")
        #expect(filmWatched.title == Film.sample[1].title, "Should be equal.")
    }
    
    @Test("`performFetches` should handle errors by updating `currentState` and calling the delegate",
          arguments: errorScenarios
    )
    func homeViewModel_performFetches_setsCorrectFailureState(
        for scenario: (systemError: Error,
                       expectedReason: HomeError.FailureReason)
    ) throws {
        let testPersistenceController = try PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let throwingController = ThrowingFetchedResultsController(context: context, errorToThrow: scenario.systemError)
        let sut = HomeViewModel(
            context: context,
            upNextFRC: throwingController,
            watchedFRC: throwingController
        )
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.fetchFailed(scenario.expectedReason)
        let expectedState = HomeViewModel.HomeState.failure(expectedError)
        
        sut.performFetches()
        
        #expect(sut.currentState == expectedState, "Should match.")
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should call the delegate once.")
        #expect(delegateSpy.receivedError == expectedError, "Should match.")
    }
    
    @Test("Adding a film to upNext should add it to `upNextFilms`, and call delegate method")
    func homeViewModel_addFilmToQueue_addsFilmToUpNext() async throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        await sut.addFilmToQueue(film: targetFilm, queue: .upNext)
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received upNext films array.")
        #expect(upNextFilms.count == 1, "Should be one.")
    }
    
    @Test("Adding a film to watched should add it to `watchedFilms`, and call delegate method")
    func homeViewModel_addFilmToQueue_addsFilmToWatched() async throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        await sut.addFilmToQueue(film: targetFilm, queue: .watched)
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received watched films array.")
        #expect(watchedFilms.count == 1, "Should be one.")
    }
    
    @Test("`addFilmToQueue` should handle errors by updating `currentState` and calling the delegate",
          arguments: errorScenarios
    )
    func homeViewModel_addFilmToQueue_onSaveError_handlesError(
        scenario: (systemError: Error,
                   expectedReason: HomeError.FailureReason)
    ) async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let sut = HomeViewModel(context: testPersistenceController.viewContext, saver: saver)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.addFailed(scenario.expectedReason)
        
        await sut.addFilmToQueue(film: Film.sample[0], queue: .upNext)
        
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should have called delegate method once.")
        #expect(delegateSpy.receivedError == expectedError, "Delegate should receive matching error.")
        #expect(sut.currentState == .failure(expectedError), "ViewModel state should transition to match failure.")
    }

    @Test("Deleting film from upNext when it's not in watched should remove it from database")
    func homeViewModel_removeFilmFromQueue_whenFilmIsInUpNextButNotInWatched_deletesItFromDatabase() async throws {
        let (sut, context) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let targetFilm = Film.sample[0]
        _ = PersistenceHelper.makeFilmMO(with: targetFilm, entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        
        await sut.removeFilmFromQueue(id: targetFilm.id, queue: .upNext)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.isEmpty, "Should be empty.")
        #expect(watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Deleting film from upNext when it's in watched should only flip upNext flag")
    func homeViewModel_removeFilmFromQueue_whenFilmIsInUpNextAndInWatched_shouldFlipFlag() async throws {
        let (sut, context) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let targetFilm = Film.sample[0]
        _ = PersistenceHelper.makeFilmMO(with: targetFilm, entity: entity, context: context, isUpNext: true, isWatched: true)
        try context.save()
        
        await sut.removeFilmFromQueue(id: targetFilm.id, queue: .upNext)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.isEmpty, "Should be empty.")
        #expect(watchedFilms.count == 1, "Should still have one in watched.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Deleting film from watched when it's not in upNext removes film from database entirely")
    func homeViewModel_removeFilmFromQueue_whenFilmInWatchedAndNotInUpNext_deletesFilmFromDatabase() async throws {
        let (sut, context) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let targetFilm = Film.sample[0]
        _ = PersistenceHelper.makeFilmMO(with: targetFilm, entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        
        await sut.removeFilmFromQueue(id: targetFilm.id, queue: .watched)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.isEmpty, "Should be empty.")
        #expect(watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Deleting film from watched when it is in upNext removes film from watched only")
    func homeViewModel_removeFilmFromQueue_whenFilmInBothWatchedAndInUpNext_deletesFilmFromWatched() async throws {
        let (sut, context) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let targetFilm = Film.sample[0]
        _ = PersistenceHelper.makeFilmMO(with: targetFilm, entity: entity, context: context, isUpNext: true, isWatched: true)
        try context.save()
        
        await sut.removeFilmFromQueue(id: targetFilm.id, queue: .watched)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.count == 1, "Should still have one in upNext.")
        #expect(watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("`removeFilmFromQueue` throws error when saving fails, updates `currentState` and calls the delegate",
          arguments: errorScenarios
    )
    func homeViewModel_removeFilmFromQueue_onSaveError_throwsError(
        scenario: (systemError: Error,
                   expectedReason: HomeError.FailureReason)
    ) async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let sut = HomeViewModel(context: context, saver: saver)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetID = "test-film-id"
        try? await context.perform {
            let mockFilm = FilmMO(context: context)
            mockFilm.id = targetID
            mockFilm.isUpNext = true
            try context.save()
        }
        let expectedError = HomeError.deleteFailed(scenario.expectedReason)
        
        await sut.removeFilmFromQueue(id: targetID, queue: .upNext)
        
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should have called delegate method once.")
        #expect(delegateSpy.receivedError == expectedError, "Delegate should receive matching error.")
        #expect(sut.currentState == .failure(expectedError), "ViewModel state should transition to match failure.")
    }
    
    @Test("`removeFilmFromQueue` doesn't throw error, and exits silently via guard when film does not exist in database")
    func homeViewModel_removeFilmFromQueue_whenFilmDoesNotExistInDatabase_doesNotThrowAndExitsCleanly() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = HomeViewModel(context: testPersistenceController.viewContext)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.removeFilmFromQueue(id: "non-existent-id", queue: .upNext)
        
        #expect(delegateSpy.didReceiveErrorCallCount == 0, "Should not call delegate method.")
    }
    
    @Test("Adding a film to upNext should add it to `upNextFilms`, and call delegate method")
    func homeViewModel_toggleFilmInQueue_addsFilmToUpNext() throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        sut.toggleFilmInQueue()
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received upNext films array.")
        #expect(upNextFilms.count == 1, "Should be one.")
    }
    
    //MARK: - SUT Helper Method
    private func makeSUTWithContext() -> (sut: HomeViewModel, context: NSManagedObjectContext) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let sut = HomeViewModel(context: context)
        return (sut, context)
    }
    
    //MARK: - Home ViewModel Delegate Spy
    final class HomeViewModelDelegateSpy: HomeViewModelDelegate {
        var upNextFilms: [Film]?
        var watchedFilms: [Film]?
        var filmsDidChangeCallCount: Int = 0
        var didReceiveErrorCallCount: Int = 0
        var receivedError: HomeError?
        
        func filmsDidChange(_ upNextFilms: [Film], _ watchedFilms: [Film]) {
            self.upNextFilms = upNextFilms
            self.watchedFilms = watchedFilms
            self.filmsDidChangeCallCount += 1
        }
        
        func didReceiveError(_ error: HomeError) {
            self.didReceiveErrorCallCount += 1
            receivedError = error
        }
    }
    
    //MARK: - Throwing Fetched Results Controller
    /// Used in test for `performFetches` failure.
    final class ThrowingFetchedResultsController: NSFetchedResultsController<FilmMO> {
        let errorToThrow: Error
        
        init(context: NSManagedObjectContext, errorToThrow: Error) {
            self.errorToThrow = errorToThrow
            
            let validRequest = NSFetchRequest<FilmMO>(entityName: "FilmMO")
            validRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            super.init(
                fetchRequest: validRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
        
        override func performFetch() throws {
            throw errorToThrow
        }
    }
    
    //MARK: - Throwing Saver
    /// Used in tests for failure when saving Core Data context.
    final class ThrowingSaver: ContextSaving, Sendable {
        let errorToThrow: Error
        
        init(errorToThrow: Error) {
            self.errorToThrow = errorToThrow
        }
        
        nonisolated func save() throws {
            throw errorToThrow
        }
    }
    
    // MARK: - System Errors Helper
    /// Used in tests involving error handling.
    nonisolated static var errorScenarios: [(systemError: Error, expectedReason: HomeError.FailureReason)] {
        [
            (CocoaError(.fileWriteOutOfSpace), .diskFull),
            (CocoaError(.persistentStoreOpen), .databaseError),
            (CocoaError(.managedObjectReferentialIntegrity), .databaseError),
            (CocoaError(.persistentStoreTypeMismatch), .databaseError),
            (CocoaError(.fileNoSuchFile), .databaseError),
            (UnknownError(), .unknown("Unknown error."))
        ]
    }
    
    //MARK: - Custom Unknown Error Helper
    /// Used in test for `performFetches` failure.
    private struct UnknownError: Error, LocalizedError {
        var errorDescription: String? { "Unknown error." }
    }
}
