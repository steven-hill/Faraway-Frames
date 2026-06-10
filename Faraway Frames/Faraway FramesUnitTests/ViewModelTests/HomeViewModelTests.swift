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
    
    @Test("`currentState` updates correctly across different error domains and codes, and delegate is called", arguments: [
        (
            error: NSError(domain: NSCocoaErrorDomain, code: NSFileWriteOutOfSpaceError, userInfo: nil) as Error,
            expectedState: HomeViewModel.HomeState.failure(.diskFull)
        ),
        (
            error: NSError(domain: NSCocoaErrorDomain, code: NSPersistentStoreOpenError, userInfo: nil) as Error,
            expectedState: HomeViewModel.HomeState.failure(.databaseAccessError)
        ),
        (
            error: NSError(domain: NSCocoaErrorDomain, code: CocoaError.managedObjectReferentialIntegrity.rawValue, userInfo: nil) as Error,
            expectedState: HomeViewModel.HomeState.failure(.databaseAccessError)
        ),
        (
            error: NSError(domain: NSCocoaErrorDomain, code: CocoaError.persistentStoreTypeMismatch.rawValue, userInfo: nil) as Error,
            expectedState: HomeViewModel.HomeState.failure(.databaseAccessError)
        ),
        (
            error: NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileNoSuchFile.rawValue, userInfo: nil) as Error,
            expectedState: HomeViewModel.HomeState.failure(.databaseAccessError)
        ),
        (
            error: UnknownError() as Error,
            expectedState: HomeViewModel.HomeState.failure(.unknown(UnknownError().localizedDescription))
        )
    ]
    )
    func homeViewModel_performFetches_setsCorrectFailureState(for scenario: (error: Error, expectedState: HomeViewModel.HomeState)) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let throwingController = ThrowingFetchedResultsController(context: context, errorToThrow: scenario.error)
        let sut = HomeViewModel(
            context: context,
            upNextFRC: throwingController,
            watchedFRC: throwingController
        )
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.performFetches()
        
        #expect(sut.currentState == scenario.expectedState)
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Adding a film to upNext should add it to `upNextFilms`, and call delegate method")
    func homeViewModel_addFilmToQueue_addsFilmToUpNext() throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        sut.addFilmToQueue(film: targetFilm, queue: .upNext)
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let upNextFilms = try #require(delegateSpy.upNextFilms, "Delegate should have received upNext films array.")
        #expect(upNextFilms.count == 1, "Should be one.")
    }
    
    @Test("Adding a film to watched should add it to `watchedFilms`, and call delegate method")
    func homeViewModel_addFilmToQueue_addsFilmToWatched() throws {
        let (sut, _) = makeSUTWithContext()
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        let targetFilm = Film.sample[0]
        
        sut.addFilmToQueue(film: targetFilm, queue: .watched)
        sut.performFetches()
        
        #expect(delegateSpy.filmsDidChangeCallCount == 1, "Should call the delegate once.")
        let watchedFilms = try #require(delegateSpy.watchedFilms, "Delegate should have received watched films array.")
        #expect(watchedFilms.count == 1, "Should be one.")
    }
    
    @Test("`addFilmToQueue` should handle errors by updating `currentState` and calling the delegate")
    func homeViewModel_addFilmToQueue_onSaveError_handlesError() async {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver()
        let sut = HomeViewModel(context: testPersistenceController.viewContext, saver: saver)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.addFilmToQueue(film: Film.sample[0], queue: .upNext)
        await Task.yield()
        
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should have called delegate method once.")
        if case .failure = sut.currentState { #expect(true) }
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
    
    @Test("`removeFilmFromQueue` catch block handles both failure cases correctly", arguments: [
        CatchBlockScenario(shouldFailOnFetch: true, shouldFailOnSave: false, displayName: "Fetch Failure Case"),
        CatchBlockScenario(shouldFailOnFetch: false, shouldFailOnSave: true, displayName: "Save Failure Case")
    ])
    func homeViewModel_removeFilmFromQueue_catchBlockTriggered(for scenario: CatchBlockScenario) async {
        let mockContext = FailingManagedObjectContext()
        mockContext.shouldFailOnFetch = scenario.shouldFailOnFetch
        mockContext.shouldFailOnSave = scenario.shouldFailOnSave
        
        let targetID = "test-film-id"
        if scenario.shouldFailOnSave {
            mockContext.seedFilm(id: targetID, isUpNext: true, isWatched: false)
        }
        
        let dummyRequest = NSFetchRequest<FilmMO>(entityName: "FilmMO")
        dummyRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let dummyUpNextFRC = NSFetchedResultsController(
            fetchRequest: dummyRequest,
            managedObjectContext: mockContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        let dummyWatchedFRC = NSFetchedResultsController(
            fetchRequest: dummyRequest,
            managedObjectContext: mockContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        let sut = HomeViewModel(context: mockContext, upNextFRC: dummyUpNextFRC, watchedFRC: dummyWatchedFRC)
        let delegateSpy = HomeViewModelDelegateSpy()
        sut.delegate = delegateSpy
        
        await sut.removeFilmFromQueue(id: targetID, queue: .upNext)
        await Task.yield()
        
        if case .failure = sut.currentState {
            #expect(true)
        } else {
            Issue.record("[\(scenario.displayName)] Expected state to be .failure, but got \(sut.currentState)")
        }
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "[\(scenario.displayName)] Delegate should be called exactly once")
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
        
        func filmsDidChange(_ upNextFilms: [Film], _ watchedFilms: [Film]) {
            self.upNextFilms = upNextFilms
            self.watchedFilms = watchedFilms
            self.filmsDidChangeCallCount += 1
        }
        
        func didReceiveError(_ error: HomeError) {
            self.didReceiveErrorCallCount += 1
        }
    }
    
    //MARK: - Throwing Fetched Results Controller
    /// Used in test for `performFetches` failure.
    final class ThrowingFetchedResultsController: NSFetchedResultsController<FilmMO> {
        let errorToThrow: Error
        
        init(context: NSManagedObjectContext, errorToThrow: Error) {
            self.errorToThrow = errorToThrow
            
            let validRequest = FilmMO.fetchRequest() as! NSFetchRequest<FilmMO>
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
    
    //MARK: - Custom Error Helper
    /// Used in test for `performFetches` failure.
    private struct UnknownError: Error, LocalizedError {
        var errorDescription: String? { "Unknown error." }
    }
    
    //MARK: - Failing Managed Object Context
    /// Used in test for `removeFilmFromQueue(id:, queue:)` failures.
    final class FailingManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        var shouldFailOnFetch = false
        var shouldFailOnSave = false
        
        enum MockError: Error {
            case forcedFetchFailure
            case forcedSaveFailure
        }
        
        convenience init() {
            let model = NSManagedObjectModel()
            let entity = NSEntityDescription()
            entity.name = "FilmMO"
            entity.managedObjectClassName = NSStringFromClass(FilmMO.self)
            
            let idAttribute = NSAttributeDescription()
            idAttribute.name = "id"
            idAttribute.attributeType = .stringAttributeType
            
            let upNextAttribute = NSAttributeDescription()
            upNextAttribute.name = "isUpNext"
            upNextAttribute.attributeType = .booleanAttributeType
            
            let watchedAttribute = NSAttributeDescription()
            watchedAttribute.name = "isWatched"
            watchedAttribute.attributeType = .booleanAttributeType
            
            entity.properties = [idAttribute, upNextAttribute, watchedAttribute]
            model.entities = [entity]
            
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            
            self.init(concurrencyType: .mainQueueConcurrencyType)
            self.persistentStoreCoordinator = coordinator
        }
        
        func seedFilm(id: String, isUpNext: Bool, isWatched: Bool) {
            let entity = NSEntityDescription.entity(forEntityName: "FilmMO", in: self)!
            let managedObject = NSManagedObject(entity: entity, insertInto: self)
            managedObject.setValue(id, forKey: "id")
            managedObject.setValue(isUpNext, forKey: "isUpNext")
            managedObject.setValue(isWatched, forKey: "isWatched")
            try! super.save()
        }
        
        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            if shouldFailOnFetch && request is NSFetchRequest<NSFetchRequestResult> {
                throw MockError.forcedFetchFailure
            }
            return try super.execute(request)
        }
        
        override func save() throws {
            if shouldFailOnSave {
                throw MockError.forcedSaveFailure
            }
            try super.save()
        }
    }
    
    //MARK: - Catch Block Scenario
    /// Used in test for `removeFilmFromQueue(id:, queue:)` failures.
    struct CatchBlockScenario: Sendable {
        let shouldFailOnFetch: Bool
        let shouldFailOnSave: Bool
        let displayName: String
    }
    
    //MARK: - Throwing Saver
    final class ThrowingSaver: ContextSaving {
        func save() throws {
            throw HomeError.diskFull
        }
    }
}
