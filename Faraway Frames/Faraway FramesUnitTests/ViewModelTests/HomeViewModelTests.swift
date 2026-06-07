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
    
    @Test("`HomeViewModel` can fetch up next films and watched films")
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
        
        #expect(delegateSpy.callCount == 1, "Should make the call once.")
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
    
    @Test("`currentState` updates correctly across different error domains and codes", arguments: [
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
        
        sut.performFetches()
        
        #expect(sut.currentState == scenario.expectedState)
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
        var callCount: Int = 0
        
        func filmsDidChange(_ upNextFilms: [Film], _ watchedFilms: [Film]) {
            self.upNextFilms = upNextFilms
            self.watchedFilms = watchedFilms
            self.callCount += 1
        }
    }
    
    //MARK: - Throwing Fetched Results Controller
    final class ThrowingFetchedResultsController: NSFetchedResultsController<FilmMO> {
        let errorToThrow: Error
        
        init(context: NSManagedObjectContext, errorToThrow: Error) {
            self.errorToThrow = errorToThrow
            
            let validRequest = FilmMO.fetchRequest()
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
    private struct UnknownError: Error, LocalizedError {
        var errorDescription: String? { "Unknown error." }
    }
}
