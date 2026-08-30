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
        let (sut,_) = makeSUTAndContext()
        
        #expect(sut.currentState == .idle, "Should be `.idle`.")
    }
    
    @Test("`currentState` is correct after fetching Up Next films and Watched films")
    func homeViewModel_currentState_afterFetchingSuccessfully_isFetchedObjects() {
        let (sut,_) = makeSUTAndContext()
        
        sut.performFetches()
        
        #expect(sut.currentState == .fetchedObjects, "Should be `.fetchedObjects`.")
    }
    
    @Test("`HomeViewModel` can fetch up next films and watched films, and calls delegate", (.tags(.persistence)))
    func homeViewModel_performFetches_whenFilmsExistInDatabase_fetchesCorrectly() throws {
        let (sut, context) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: Film.sample[0],
            isUpNext: true,
            isWatched: false
        )
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: Film.sample[1],
            isUpNext: false,
            isWatched: true
        )
        
        sut.performFetches()
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
        #expect(sut.upNextFilms.count == 1, "Should be one.")
        let filmUpNext = try #require(sut.upNextFilms.first, "Should contain a film.")
        #expect(filmUpNext.id == Film.sample[0].id, "Should be equal.")
        #expect(filmUpNext.title == Film.sample[0].title, "Should be equal.")
        #expect(sut.watchedFilms.count == 1, "Should be one.")
        let filmWatched = try #require(sut.watchedFilms.first, "Should contain a film.")
        #expect(filmWatched.id == Film.sample[1].id, "Should be equal.")
        #expect(filmWatched.title == Film.sample[1].title, "Should be equal.")
    }
    
    @Test("`HomeViewModel` upNextFilms and watchedFilms are empty if `performFetches` returns no results, and calls delegate", (.tags(.persistence)))
    func homeViewModel_performFetches_whenFetchesReturnNoResults_arraysAreEmpty() {
        let (sut, _) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.performFetches()
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
        #expect(sut.upNextFilms.isEmpty == true, "Should be empty.")
        #expect(sut.watchedFilms.isEmpty == true, "Should be empty.")
    }
    
    @Test("When `controllerDidChangeContent` is called, it should call the delegate")
    func homeViewModel_controllerDidChangeContent_triggersDelegate() {
        let (sut, _) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let dummyController = NSFetchedResultsController<NSFetchRequestResult>()
        
        sut.controllerDidChangeContent(dummyController)
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("`performFetches` should handle errors by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeViewModel_performFetches_whenThereIsAnError_setsCorrectFailureState(
        for scenario: (
            systemError: Error,
            expectedReason: PersistenceFailureReason
        )
    ) throws {
        let sut = try makeSUTWithThrowingFRC(error: scenario.systemError)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.fetchFailed(scenario.expectedReason)
        let expectedState = HomeViewModel.HomeState.failure(expectedError)
        
        sut.performFetches()
        
        #expect(sut.currentState == expectedState, "Should match.")
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Image loading request returns fallback image when URL is invalid")
    func homeViewModel_getImage_whenURLIsInvalid_returnsFallback() async {
        let (sut, _) = makeSUTAndImageLoader(shouldDownloadSucceed: false)
        let targetFilm = Film.sample[0]
        
        let returnedImage = await sut.getImage(for: targetFilm)
        
        #expect(returnedImage == SFSymbols.movieClapper, "Should instantly catch the invalid URL and provide the fallback image.")
    }
    
    @Test("Image loading request returns the downloaded image when network request succeeds")
    func homeViewModel_getImage_whenRequestSucceeds_returnsDownloadedImage() async {
        let (sut, _) = makeSUTAndContext()
        let targetFilm = Film.sample[0]
        
        let returnedImage = await sut.getImage(for: targetFilm)
        
        #expect(returnedImage == SFSymbols.popcorn, "Should return the downloaded image (MockImageLoader stubbed to return `SFSymbols.popcorn` in success case).")
    }
    
    @Test("Image loading request returns the fallback image when network request fails")
    func homeViewModel_getImage_whenRequestFails_returnsFallbackImage() async {
        let (sut, _) = makeSUTAndImageLoader(shouldDownloadSucceed: false)
        let targetFilm = Film.sample[0]
        
        let returnedImage = await sut.getImage(for: targetFilm)
        
        #expect(returnedImage == SFSymbols.movieClapper, "Should return the fallback image.")
    }
    
    @Test("Image loading request catches cancellation and returns fallback image")
    func homeViewModel_getImage_whenTaskIsCancelledMidFlight_returnsFallback() async {
        let (sut, _) = makeSUTAndImageLoader(shouldDownloadSucceed: false)
        let targetFilm = Film.sample[0]
        let task = Task {
            await sut.getImage(for: targetFilm)
        }
        task.cancel()
        
        let resultImage = await task.value
        
        #expect(resultImage == SFSymbols.movieClapper, "Cooperative cancellation should cause the method to bypass normal returns and return the fallback image.")
    }
    
    @Test("`checkCachesForFilmPoster` calls method on `imageLoader`")
    func homeViewModel_checkCachesForFilmPoster_callsCorrectMethodOnImageLoaderOnce() {
        let (sut, mockImageLoader) = makeSUTAndImageLoader(shouldDownloadSucceed: false)
        
        _ = sut.checkCachesForFilmPoster(for: Film.sample[0])
        
        #expect(mockImageLoader.checkCacheCallCount == 1, "Should have called `checkCache` on `imageLoader` once.")
    }
    
    @Test("Adding a film to upNext should add it to `upNextFilms`, and call delegate method", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_addsFilmToUpNext() async {
        let (sut, _) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .upNext, action: .add)
        sut.performFetches()
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
        #expect(sut.upNextFilms.count == 1, "Should be one.")
    }
    
    @Test("Adding a film to watched should add it to `watchedFilms`, and call delegate method", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_addsFilmToWatched() async {
        let (sut, _) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.toggleFilmInQueue(film: Film.sample[0], queue: .watched, action: .add)
        sut.performFetches()
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
        #expect(sut.watchedFilms.count == 1, "Should be one.")
    }
    
    @Test("`toggleFilmInQueue` should handle add film errors by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeViewModel_toggleFilmInQueue_onSaveError_whenAddingFilm_handlesError(
        scenario: (
            systemError: Error,
            expectedReason: PersistenceFailureReason
        )
    ) async {
        let (sut,_) = makeSUTAndContextWithThrowingSaver(error: scenario.systemError)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.addFailed(scenario.expectedReason)
        
        await sut.toggleFilmInQueue(film: Film.sample[0], queue: .upNext, action: .add)
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
        #expect(sut.currentState == .failure(expectedError), "ViewModel state should transition to match the add failure signature.")
    }
    
    @Test("`toggleFilmInQueue` should handle delete film errors by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func homeViewModel_toggleFilmInQueue_onSaveError_whenDeletingFilm_handlesError(
        scenario: (
            systemError: Error,
            expectedReason: PersistenceFailureReason
        )
    ) async throws {
        let (sut, context) = makeSUTAndContextWithThrowingSaver(error: scenario.systemError)
        let sampleFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: sampleFilm,
            isUpNext: true,
            isWatched: false
        )
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let expectedError = HomeError.removeFailed(scenario.expectedReason)
        
        await sut.toggleFilmInQueue(film: sampleFilm, queue: .upNext, action: .remove)
        
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
        #expect(sut.currentState == .failure(expectedError), "ViewModel state should transition to match the delete failure signature.")
    }

    @Test("Removing film from upNext when it's not in watched should remove it from database entirely, and call delegate", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmInUpNextButNotInWatchedIsRemoved_deletesItFromDatabase() async throws {
        let (sut, context) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: targetFilm,
            isUpNext: true,
            isWatched: false
        )
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .upNext, action: .remove)
        
        sut.performFetches()
        
        #expect(sut.upNextFilms.isEmpty, "Should be empty.")
        #expect(sut.watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Removing film from upNext when it's in watched should only flip upNext flag, and call delegate", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmIsInUpNextAndInWatched_shouldFlipFlag() async throws {
        let (sut, context) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: targetFilm,
            isUpNext: true,
            isWatched: true
        )
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .upNext, action: .remove)
        
        sut.performFetches()
        
        #expect(sut.upNextFilms.isEmpty, "Should be empty.")
        #expect(sut.watchedFilms.count == 1, "Should still have one in watched.")
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Removing film from watched when it's not in upNext removes film from database entirely, and calls delegate", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmInWatchedAndNotInUpNext_deletesFilmFromDatabase() async throws {
        let (sut, context) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: targetFilm,
            isUpNext: false,
            isWatched: true
        )

        await sut.toggleFilmInQueue(film: targetFilm, queue: .watched, action: .remove)
        sut.performFetches()
        
        #expect(sut.upNextFilms.isEmpty, "Should be empty.")
        #expect(sut.watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Removing film from watched when it is in upNext removes film from watched only, and calls delegate", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmInBothWatchedAndInUpNext_deletesFilmFromWatched() async throws {
        let (sut, context) = makeSUTAndContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: targetFilm,
            isUpNext: true,
            isWatched: true
        )
        
        await sut.toggleFilmInQueue(film: targetFilm, queue: .watched, action: .remove)
        sut.performFetches()
        
        #expect(sut.upNextFilms.count == 1, "Should still have one in upNext.")
        #expect(sut.watchedFilms.isEmpty, "Should be empty.")
        #expect(delegateSpy.didUpdateCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("`toggleFilmInQueue` doesn't throw error or call delegate, but exits silently via guard when film does not exist in database", (.tags(.persistence)))
    func homeViewModel_toggleFilmInQueue_whenFilmDoesNotExistInDatabase_doesNotThrowAndExitsCleanly() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let filmQueueService = FilmQueueService(context: context)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.toggleFilmInQueue(film: Film.sample[0], queue: .upNext, action: .remove)
        
        #expect(delegateSpy.didUpdateCallCount == 0, "Should not call delegate method.")
    }
    
    @Test("Up Next film lookup returns film when it exists in array")
    func homeViewModel_lookupUpNextFilm_whenFilmExistsInArray_returnsFilm() throws {
        let (sut, context) = makeSUTAndContext()
        let targetFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: targetFilm,
            isUpNext: true,
            isWatched: false
        )
        sut.performFetches()
        
        let result = sut.lookupUpNextFilm(for: targetFilm.id)
        
        #expect(result != nil, "Result should return a film.")
    }
    
    @Test("Up Next film lookup returns nil when film does not exist in array")
    func homeViewModel_lookupUpNextFilm_whenFilmIsNotInArray_returnsNil() throws {
        let (sut, _) = makeSUTAndContext()
        sut.performFetches()
        
        let result = sut.lookupUpNextFilm(for: Film.sample[0].id)
        
        #expect(result == nil, "Result should return nil.")
    }
    
    @Test("Watched film lookup returns film when it exists in array")
    func homeViewModel_lookupWatchedFilm_whenFilmExistsInArray_returnsFilm() throws {
        let (sut, context) = makeSUTAndContext()
        let targetFilm = Film.sample[0]
        _ = try PersistenceHelper.saveFilmToDatabase(
            context: context,
            film: targetFilm,
            isUpNext: false,
            isWatched: true
        )
        sut.performFetches()
        
        let result = sut.lookupWatchedFilm(for: targetFilm.id)
        
        #expect(result != nil, "Result should return a film.")
    }
    
    @Test("Watched film lookup returns nil when film does not exist in array")
    func homeViewModel_lookupUpWatchedFilm_whenFilmIsNotInArray_returnsNil() throws {
        let (sut, _) = makeSUTAndContext()
        let targetFilm = Film.sample[0].id
        sut.performFetches()
        
        let result = sut.lookupWatchedFilm(for: targetFilm)
        
        #expect(result == nil, "Result should return nil.")
    }
    
    //MARK: - SUT Helper Methods
    private func makeSUTAndContext() -> (
        sut: HomeViewModel,
        context: NSManagedObjectContext
    ) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: FilmQueueService(context: context)
        )
        return (sut, context)
    }
    
    private func makeSUTWithThrowingFRC(error: Error) throws -> HomeViewModel {
        let testPersistenceController = try PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let throwingController = ThrowingFetchedResultsController(
            context: context,
            errorToThrow: error
        )
        return HomeViewModel(
            upNextFRC: throwingController,
            watchedFRC: throwingController,
            imageLoader: MockImageLoader(),
            filmQueueService: FilmQueueService(context: context)
        )
    }
    
    private func makeSUTAndContextWithThrowingSaver(error: Error) -> (
        sut: HomeViewModel,
        context: NSManagedObjectContext
    ) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let saver = ThrowingSaver(errorToThrow: error)
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: MockImageLoader(),
            filmQueueService: FilmQueueService(context: context, saver: saver)
        )
        return (sut, context)
    }
    
    private func makeSUTAndImageLoader(shouldDownloadSucceed: Bool) -> (
        sut: HomeViewModel,
        mockImageLoader: MockImageLoader
    )  {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let mockFRCFactory = MockFRCFactory()
        let mockUpNextFRC = mockFRCFactory.makeHomeUpNextFRC(context: context)
        let mockWatchedFRC = mockFRCFactory.makeHomeWatchedFRC(context: context)
        let mockImageLoader = MockImageLoader()
        mockImageLoader.shouldSucceed = shouldDownloadSucceed
        let sut = HomeViewModel(
            upNextFRC: mockUpNextFRC,
            watchedFRC: mockWatchedFRC,
            imageLoader: mockImageLoader,
            filmQueueService: FilmQueueService(context: context)
        )
        return (sut, mockImageLoader)
    }
    
    //MARK: - Home View Model Delegate Spy
    final class HomeViewModelDelegateSpy: HomeViewModelDelegate {
        var didUpdateCallCount: Int = 0
        
        func homeViewModelDidUpdate() {
            didUpdateCallCount += 1
        }
    }
}
