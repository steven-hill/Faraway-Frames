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
    func homeViewModel_currentState_onInit_isIdle() {
        let (sut,_) = makeSUTWithContext()
        
        #expect(sut.currentState == .idle, "Should be `.idle`.")
    }
    
    @Test("`currentState` is correct after fetching Up Next films and Watched films")
    func homeViewModel_currentState_afterFetchingSuccessfully_isFetchedObjects() {
        let (sut,_) = makeSUTWithContext()
        
        sut.performFetches()
        
        #expect(sut.currentState == .fetchedObjects, "Should be `.fetchedObjects`.")
    }
    
    @Test("`HomeViewModel` can fetch up next films and watched films, and calls delegate", (.tags(.persistence)))
    func homeViewModel_performFetches_whenFilmsExistInDatabase_fetchesCorrectly() throws {
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
    
    @Test("`HomeViewModel` upNextFilms and watchedFilms are empty if `performFetches` returns no results, and calls delegate", (.tags(.persistence)))
    func homeViewModel_performFetches_whenFetchesReturnNoResults_arraysAreEmpty() throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received upNextFilms array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received watchedFilms array.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        #expect(upNextFilms.isEmpty == true, "Should be empty.")
        #expect(watchedFilms.isEmpty == true, "Should be empty.")
    }
    
    @Test("When `controllerDidChangeContent` is called, it should call the delegate")
    func homeViewModel_controllerDidChangeContent_triggersDelegate() {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let dummyController = NSFetchedResultsController<NSFetchRequestResult>()
        
        sut.controllerDidChangeContent(dummyController)
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("`performFetches` should handle errors by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeViewModel_performFetches_whenThereIsAnError_setsCorrectFailureState(
        for scenario: (systemError: Error,
                       expectedReason: PersistenceFailureReason)
    ) throws {
        let testPersistenceController = try PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let throwingController = ThrowingFetchedResultsController(context: context, errorToThrow: scenario.systemError)
        let sut = HomeViewModel(
            upNextFRC: throwingController,
            watchedFRC: throwingController, imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService
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
    
    @Test("Image loading request returns fallback image when URL is invalid")
    func homeViewModel_getImage_whenURLIsInvalid_returnsFallback() async {
        let (sut, _) = makeSUTWithContext()
        let targetFilm = Film.sample[0]
        
        let returnedImage = await sut.getImage(for: targetFilm)
        
        #expect(returnedImage == SFSymbols.movieClapper, "Should instantly catch the invalid URL and provide the fallback image.")
    }
    
    @Test("Adding a film to upNext should add it to `upNextFilms`, and call delegate method", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_addsFilmToUpNext() async throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .upNext, action: .add)
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received upNext films array.")
        #expect(upNextFilms.count == 1, "Should be one.")
    }
    
    @Test("Adding a film to watched should add it to `watchedFilms`, and call delegate method", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_addsFilmToWatched() async throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .watched, action: .add)
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received watched films array.")
        #expect(watchedFilms.count == 1, "Should be one.")
    }
    
    @Test("`toggleFilmInQueue` should handle add film errors by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeViewModel_toggleFilmInQueue_onSaveError_whenAddingFilm_handlesError(
        scenario: (systemError: Error,
                   expectedReason: PersistenceFailureReason)
    ) async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let context = testPersistenceController.viewContext
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context, saver: saver)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.addFailed(scenario.expectedReason)
        
        await sut.toggleFilmInQueue(film: Film.sample[0], queue: .upNext, action: .add)
        
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should have called delegate method once on add failure.")
        #expect(delegateSpy.receivedError == expectedError, "Delegate should receive matching add error context case.")
        #expect(sut.currentState == .failure(expectedError), "ViewModel state should transition to match the add failure signature.")
    }
    
    @Test("`toggleFilmInQueue` should handle delete film errors by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeViewModel_toggleFilmInQueue_onSaveError_whenDeletingFilm_handlesError(
        scenario: (systemError: Error,
                   expectedReason: PersistenceFailureReason)
    ) async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let context = testPersistenceController.viewContext
        let sampleFilm = Film.sample[0]
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try? context.save()
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context, saver: saver)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService
        )
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.removeFailed(scenario.expectedReason)
        
        await sut.toggleFilmInQueue(film: sampleFilm, queue: .upNext, action: .remove)
        
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should have called delegate method once on removal failure.")
        #expect(delegateSpy.receivedError == expectedError, "Delegate should receive matching removal error context case.")
        #expect(sut.currentState == .failure(expectedError), "ViewModel state should transition to match the delete failure signature.")
    }

    @Test("Removing film from upNext when it's not in watched should remove it from database entirely", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmInUpNextButNotInWatchedIsRemoved_deletesItFromDatabase() async throws {
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
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .upNext, action: .remove)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.isEmpty, "Should be empty.")
        #expect(watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Removing film from upNext when it's in watched should only flip upNext flag", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmIsInUpNextAndInWatched_shouldFlipFlag() async throws {
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
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .upNext, action: .remove)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.isEmpty, "Should be empty.")
        #expect(watchedFilms.count == 1, "Should still have one in watched.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Removing film from watched when it's not in upNext removes film from database entirely", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmInWatchedAndNotInUpNext_deletesFilmFromDatabase() async throws {
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
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .watched, action: .remove)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.isEmpty, "Should be empty.")
        #expect(watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Removing film from watched when it is in upNext removes film from watched only", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmInBothWatchedAndInUpNext_deletesFilmFromWatched() async throws {
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
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .watched, action: .remove)
        
        sut.performFetches()
        
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received a films array.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received a films array.")
        #expect(upNextFilms.count == 1, "Should still have one in upNext.")
        #expect(watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("`toggleFilmInQueue` doesn't throw error, and exits silently via guard when film does not exist in database", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmDoesNotExistInDatabase_doesNotThrowAndExitsCleanly() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.toggleFilmInQueue(film: Film.sample[0], queue: .upNext, action: .remove)
        
        #expect(delegateSpy.didReceiveErrorCallCount == 0, "Should not call delegate method.")
    }
    
    @Test("Up Next film lookup returns film when it exists in array")
    func homeViewModel_lookupUpNextFilm_whenFilmExistsInArray_returnsFilm() throws {
        let (sut, context) = makeSUTWithContext()
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        
        let targetFilm = Film.sample[0].id
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try context.save()
        sut.performFetches()
        
        let result = sut.lookupUpNextFilm(for: targetFilm)
        
        #expect(result != nil, "Result should return a film.")
    }
    
    @Test("Up Next film lookup returns nil when film does not exist in array")
    func homeViewModel_lookupUpNextFilm_whenFilmIsNotInArray_returnsNil() throws {
        let (sut, _) = makeSUTWithContext()
        let targetFilm = Film.sample[0].id
        sut.performFetches()
        
        let result = sut.lookupUpNextFilm(for: targetFilm)
        
        #expect(result == nil, "Result should return nil.")
    }
    
    @Test("Watched film lookup returns film when it exists in array")
    func homeViewModel_lookupWatchedFilm_whenFilmExistsInArray_returnsFilm() throws {
        let (sut, context) = makeSUTWithContext()
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: "FilmMO", in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let targetFilm = Film.sample[0].id
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: false, isWatched: true)
        try context.save()
        sut.performFetches()
        
        let result = sut.lookupWatchedFilm(for: targetFilm)
        
        #expect(result != nil, "Result should return a film.")
    }
    
    @Test("Watched film lookup returns nil when film does not exist in array")
    func homeViewModel_lookupUpWatchedFilm_whenFilmIsNotInArray_returnsNil() throws {
        let (sut, _) = makeSUTWithContext()
        let targetFilm = Film.sample[0].id
        sut.performFetches()
        
        let result = sut.lookupWatchedFilm(for: targetFilm)
        
        #expect(result == nil, "Result should return nil.")
    }
    
    //MARK: - SUT Helper Method
    private func makeSUTWithContext() -> (sut: HomeViewModel, context: NSManagedObjectContext) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockUpNextFRC = PersistenceHelper.makeMockUpNextFRC(context: context)
        let mockWatchedFRC = PersistenceHelper.makeMockWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC, imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService)
        return (sut, context)
    }
    
    //MARK: - Home View Model Delegate Spy
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
}
