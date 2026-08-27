//
//  FilmDetailViewModelTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 05/02/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit
import CoreData

@MainActor
struct FilmDetailViewModelTests {
    
    @Test func filmDetailViewModel_currentStateOnInit_isNoFilmSelected() {
        let sut = makeSUT()
        
        #expect(sut.currentState == .noFilmSelected, "Should be `.noFilmSelected` on init.")
    }

    @Test func filmDetailViewModel_whenFilmIsNil_setsCurrentStateToNoFilmSelectedAndCallsDelegate() {
        let sut = makeSUT()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        
        sut.updateUI()
        
        #expect(sut.currentState == .noFilmSelected, "Should be `.noFilmSelected` when film is nil.")
        #expect(spy.updateWithEmptyStateCallCount == 1, "Should call delegate method once.")
    }
    
    @Test("When a film is set, `currentState` should be updated, but not `filmWasUpdated`.")
    func filmDetailViewModel_whenFilmIsNotNil_updatesCurrentStateAndFRCButNotFilmWasUpdated() {
        let film = Film.sample[0]
        let sut = makeSUT()
        sut.film = film
        sut.setFilm()
        
        switch sut.currentState {
        case .noFilmSelected:
            Issue.record("Expected state to be `.content`, but it was `.noFilmSelected`.")
        case .content(let displayModel, _):
            #expect(displayModel.title == film.title, "Should match.")
            #expect(displayModel.visualOriginalTitles == "\(film.originalTitle)\n\(film.originalTitleRomanised)", "Should match.")
        case .fetchFailure:
            Issue.record("Expected state to be `.content`, but it was `.fetchFailure`.")
        case .error(_, _, _):
            Issue.record("Expected state to be `.content`, but it was `.error`.")
        }
        #expect(sut.filmWasUpdated == false, "Should still be false.")
    }
    
    @Test("When the view model is initialised without a film, `currentState` should be updated but not `detailFRC` or `filmWasUpdated`.")
    func filmDetailViewModel_setFilm_whenFilmIsNil_updatesCurrentStateButNotFilmWasUpdatedOrFRC() {
        let sut = makeSUT()
        
        sut.setFilm()
        
        #expect(sut.currentState == .noFilmSelected, "Should update the state to `.noFilmSelected` when film is nil.")
        #expect(sut.filmWasUpdated == false, "Should still be false.")
    }
    
    @Test("View model fetches film with correct values from the database if it exists there")
    func filmDetailViewModel_performFetch_fetchesFilmFromDatabaseIfItExists() throws {
        let (sut, context) = makeSUTAndContext()
        let delegateSpy = FilmDetailViewModelSpy()
        sut.delegate = delegateSpy
        let film = Film.sample[0]
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: Persistence.entityname, in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let filmMO = PersistenceHelper.makeFilmMO(
            with: film,
            entity: entity,
            context: context,
            isUpNext: true,
            isWatched: true
        )
        try? context.save()
        sut.film = film
        sut.setFilm()
        #expect(delegateSpy.updateFilmDetailsCallCount == 1, "Should call the delegate.")
        
        sut.performFetch()
        sut.handleFilmUpdate(filmMO)
        
        if case .content(let displayModel,_) = sut.currentState {
            #expect(displayModel.isUpNext == true, "Should be true.")
            #expect(displayModel.isWatched == true, "Should be true.")
        }
        #expect(delegateSpy.updateFilmDetailsCallCount == 2, "Should call the delegate again.")
    }
    
    @Test("When `detailFRC` encounters an error fetching film, error should be handled by updating `currentState` and calling the delegate",
          (.tags(.persistence)),
          arguments: PersistenceHelper.errorScenarios
    )
    func filmDetailViewModel_performsFetch_whenThereIsAnError_setsCorrectFailureState(
        for scenario: (systemError: Error,
                       expectedReason: PersistenceFailureReason)
    ) {
        let sut = makeSUTWithThrowingFRC(error: scenario.systemError)
        let delegateSpy = FilmDetailViewModelSpy()
        sut.delegate = delegateSpy
        let expectedError = FilmDetailError.fetchFailed(scenario.expectedReason)
        let film = Film.sample[0]
        sut.film = film
        sut.setFilm()
        
        sut.performFetch()
        
        #expect(sut.currentState == .fetchFailure(expectedError, film), "Should be `.fetchFailure`.")
        #expect(delegateSpy.didReceiveErrorCallCount == 1, "Should call the delegate once.")
    }
    
    @Test("Quick selection of films ignores the results of the cancelled task", .tags(.networkRequest))
    func filmDetailViewModel_setFilm_cancelsPreviousImageDownloadTask() async {
        let (sut, mockImageLoader) = makeSUTAndMockImageLoader()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let filmA = Film.sample[0]
        let filmB = Film.sample[1]
        sut.film = filmA
        
        sut.setFilm()
        let taskA = sut.imageLoadTask
        await Task.yield()
        #expect(mockImageLoader.loadCount == 1)

        sut.film = filmB
        sut.setFilm()
        #expect(taskA?.isCancelled == true, "taskA should be cancelled.")
        await Task.yield()
        #expect(mockImageLoader.loadCount == 2)

        mockImageLoader.resume(shouldSucceed: true)
        mockImageLoader.resume(shouldSucceed: true)
        await Task.yield()

        #expect(spy.updateFilmDetailsCallCount == 3, "Should be called three times in total; once for filmA's initial content, twice for filmB's initial content and its movie banner.")
    }

    @Test(.tags(.networkRequest))
    func filmDetailViewModel_getMovieBanner_whenFailedToDownloadMovieBannerImage_returnsFallbackImage() async {
        let (sut, mockImageLoader) = makeSUTAndMockImageLoader()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        
        mockImageLoader.resume(shouldSucceed: false)
        
        if case .content(let displayModel, let image) = sut.currentState {
            #expect(image == SFSymbols.movieClapper, "Should show the film details with `movieclapper` as a fallback image.")
            #expect(sut.currentState == .content(displayModel: displayModel, image: image), "Should have a `FilmDetailDisplayModel` and an image.")
            #expect(spy.updateFilmDetailsCallCount == 2, "Should have called `didUpdateFilmDetails()` twice; once for the film object, and again for the image.")
        }
    }
    
    @Test("Deallocating the view model cancels any active image download tasks", .tags(.networkRequest))
    func filmDetailViewModel_deinit_cancelsActiveImageLoadTask() async {
        var sut: FilmDetailViewModel? = makeSUT()
        let film = Film.sample[0]
        sut?.film = film
        sut?.setFilm()
        let capturedTask = sut?.imageLoadTask
        #expect(capturedTask?.isCancelled == false, "Should not be cancelled.")
        #expect(sut?.imageLoadTask != nil, "Should not be nil.")
        
        sut = nil
        await Task.yield()
        
        #expect(capturedTask?.isCancelled == true, "Should be marked as cancelled.")
        #expect(sut?.imageLoadTask == nil, "Should be nil.")
    }
    
    @Test("Verifies that the display model formats the Japanese title and range correctly for VoiceOver")
    func filmDetailViewModel_displayModel_setsCorrectAccessibilityPropertiesForOriginalTitle() {
        let film = Film.sample[0]
        
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: film)
        let attributedLabel = displayModel.spokenJapaneseTitle
        let expectedPrefix = "Original title: "
        #expect(attributedLabel.string == "\(expectedPrefix)\(film.originalTitle)")
        
        var range = NSRange()
        let prefixLength = (expectedPrefix as NSString).length
        let languageAttribute = attributedLabel.attribute(
            .accessibilitySpeechLanguage,
            at: prefixLength,
            effectiveRange: &range
        ) as? String
        
        #expect(languageAttribute == "ja", "The Japanese text range must be explicitly tagged with 'ja'.")
        #expect(range.location == prefixLength, "Should be equal.")
        #expect(range.length == (film.originalTitle as NSString).length, "Should be equal.")
    }
    

    @Test("Verifies direct property pass-through mapping from `Film`")
    func filmDetailViewModel_displayModel_mapsBasicPropertiesDirectly() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.title == "Castle in the Sky")
        #expect(displayModel.producer == "Isao Takahata")
    }
    
    @Test("Verifies localised default headers and composite newline title spacing configurations")
    func filmDetailViewModel_displayModel_formatsCompositeTitlesAndStaticHeaders() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.synopsisTitle == NSLocalizedString("Synopsis", comment: ""))
        #expect(displayModel.visualOriginalTitles == "天空の城ラピュタ\nTenkū no shiro Rapyuta")
    }
    
    @Test("Verifies bullet formatting and clean text assembly for release metadata and duration text labels")
    func filmDetailViewModel_displayModel_formatsReleaseYearAndDurationLabels() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.releaseYearAndDurationText == "1986 • 124 mins")
        #expect(displayModel.releaseYearAndDurationAccessibilityLabel == "Released in 1986, running time 124 minutes.")
    }
    
    @Test("Verifies speech accessibility labels for credits strings")
    func filmDetailViewModel_displayModel_formatsCreditsAccessibilityLabel() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        
        #expect(displayModel.creditsAccessibilityLabel == "Credits. Directed by Hayao Miyazaki. Produced by Isao Takahata.")
    }
    
    @Test("Verifies color coding ranges and string layout rules for the Rotten Tomatoes attributed score label")
    func filmDetailViewModel_displayModel_formatsRottenTomatoesScoreTextAndColorRanges() {
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: Film.sample[0])
        let scoreAttribute = displayModel.rottenTomatoesScoreText
        
        #expect(scoreAttribute.string == "Rotten Tomatoes 95%", "Should be equal.")
        
        var prefixRange = NSRange()
        let prefixColor = scoreAttribute.attribute(
            .foregroundColor,
            at: 0,
            effectiveRange: &prefixRange
        ) as? UIColor
        
        #expect(prefixColor == UIColor.systemRed, "The 'Rotten Tomatoes' text prefix must be systemRed.")
        #expect(prefixRange.location == 0, "Should be 0.")
        #expect(prefixRange.length == 16, "Should be 16.")
        
        var scoreRange = NSRange()
        let scoreColor = scoreAttribute.attribute(
            .foregroundColor,
            at: 16,
            effectiveRange: &scoreRange
        ) as? UIColor
        
        let expectedScoreLength = ("Rotten Tomatoes 95%" as NSString).length - 16
        #expect(scoreColor == UIColor.secondaryLabel, "The numeric percentage value block must be secondaryLabel.")
        #expect(scoreRange.location == 16, "Should be 16.")
        #expect(scoreRange.length == expectedScoreLength, "Should be equal.")
    }
    
    @Test("`updateStatus` updates `currentState` and `filmWasUpdated` when `upNext` persistent change completes successfully", .tags(.persistence))
    func filmDetailViewModel_updateStatus_whenUpNextChangeIsSuccessful_updatesCurrentStateAndFilmWasUpdatedFlag() async {
        let targetFilm = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService
        )
        sut.film = targetFilm
        sut.setFilm()
        
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        
        if case .content(let displayModel, _) = sut.currentState {
            #expect(displayModel.isUpNext == true)
        } else {
            Issue.record("State should be .content with an isUpNext value updated to true.")
        }
        #expect(sut.filmWasUpdated == true, "Should be true.")
    }
    
    @Test("`updateStatus` updates `currentState` and `filmWasUpdated` when `watched` persistent change completes successfully", .tags(.persistence))
    func filmDetailViewModel_updateStatus_whenWatchedChangeIsSuccessful_updatesCurrentStateAndFilmWasUpdatedFlag() async {
        let targetFilm = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService
        )
        sut.film = targetFilm
        sut.setFilm()
        
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .add)
        
        if case .content(let displayModel, _) = sut.currentState {
            #expect(displayModel.isWatched == true)
        } else {
            Issue.record("State should be .content with an isWatched value updated to true.")
        }
        #expect(sut.filmWasUpdated == true, "Should be true.")
    }
    
    @Test("Adding a film to upNext should call delegate method only if status changes to true - helps prevent duplicates and unnecessary delegate method calls", .tags(.persistence))
    func filmDetailViewModel_updateStatus_addFilmToUpNext_callsDelegateMethod() async {
        let sut = makeSUT()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let targetFilm = Film.sample[0]
        
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        
        #expect(spy.upNextStatusChangeCallCount == 1, "Should call delegate method only when adding a film to upNext.")
        
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        
        #expect(spy.upNextStatusChangeCallCount == 1, "Should not call delegate method because the status did not change.")
    }
    
    @Test("Adding a film to watched should call delegate method only if status changes to true - helps prevent duplicates and unnecessary delegate method calls", .tags(.persistence))
    func filmDetailViewModel_updateStatus_addFilmToWatched_callsDelegateMethod() async {
        let sut = makeSUT()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let targetFilm = Film.sample[0]
        
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .add)
        
        #expect(spy.watchedStatusChangeCallCount == 1, "Should call delegate method only when adding a film to upNext.")
        
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .add)
        
        #expect(spy.watchedStatusChangeCallCount == 1, "Should not call delegate method because the status did not change.")
    }
    
    @Test("Removing a film from upNext should call delegate method only if film exists in database", .tags(.persistence))
    func filmDetailViewModel_updateStatus_removeFilmFromUpNext_callsDelegateMethod() async {
        let sut = makeSUT()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let targetFilm = Film.sample[0]
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        #expect(spy.upNextStatusChangeCallCount == 1, "Should call delegate method when adding a film to upNext.")
        
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .remove)
        
        #expect(spy.upNextStatusChangeCallCount == 2, "Should call delegate method again when removing a film from upNext.")
                
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .remove)
        
        #expect(spy.upNextStatusChangeCallCount == 2, "Should not call delegate method because the film no longer exists in the database.")
    }
    
    @Test("Removing a film from watched should call delegate method", .tags(.persistence))
    func filmDetailViewModel_updateStatus_removeFilmFromWatched_callsDelegateMethod() async {
        let sut = makeSUT()
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let targetFilm = Film.sample[0]

        await sut.updateStatus(for: targetFilm, queue: .watched, action: .add)
        #expect(spy.watchedStatusChangeCallCount == 1, "Should call delegate method when adding a film to watched.")
        
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .remove)
        #expect(spy.watchedStatusChangeCallCount == 2, "Should call delegate method again when removing a film from watched.")
                
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .remove)
        
        #expect(spy.watchedStatusChangeCallCount == 2, "Should not call delegate method because the film no longer exists in the database.")
    }
    
    @Test("`updateStatus` should handle add film to upNext errors by updating `currentState` and triggering delegate method call",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func filmDetailViewModel_updateStatus_onSaveError_whenAddingFilmToUpNext_handlesError(
        scenario: (systemError: Error,
                   expectedReason: PersistenceFailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let expectedError = FilmDetailError.addFailed(scenario.expectedReason)
        
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        
        #expect(sut.currentState == .error(expectedError, targetFilm, .upNext), "Should be updated to error.")
        #expect(spy.didReceiveErrorCallCount == 1, "Should have called delegate method once on add failure.")
    }
    
    @Test("`updateStatus` should handle remove film from upNext errors by updating `currentState` and triggering delegate method call",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func filmDetailViewModel_updateStatus_onSaveError_whenRemovingFilmFromUpNext_handlesError(
        scenario: (systemError: Error,
                   expectedReason: PersistenceFailureReason)
    ) async throws {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: context, saver: saver)
        let targetFilm = Film.sample[0]
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: Persistence.entityname, in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: true, isWatched: false)
        try? context.save()
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: context,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let expectedError = FilmDetailError.removeFailed(scenario.expectedReason)
        
        await sut.updateStatus(for: targetFilm, queue: .upNext, action: .remove)
        
        #expect(sut.currentState == .error(expectedError, targetFilm, .upNext), "Should be updated to error.")
        #expect(spy.didReceiveErrorCallCount == 1, "Should have called delegate method once on add failure.")
    }
    
    @Test("`updateStatus` should handle add film to watched errors by updating `currentState` and triggering delegate method call",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func filmDetailViewModel_updateStatus_onSaveError_whenAddingFilmToWatched_handlesError(
        scenario: (systemError: Error,
                   expectedReason: PersistenceFailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let expectedError = FilmDetailError.addFailed(scenario.expectedReason)
        
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .add)
        
        #expect(sut.currentState == .error(expectedError, targetFilm, .watched), "Should be updated to error.")
        #expect(spy.didReceiveErrorCallCount == 1, "Should have called delegate method once on add failure.")
    }
    
    @Test("`updateStatus` should handle remove film from watched errors by updating `currentState` and triggering delegate method call",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func filmDetailViewModel_updateStatus_onSaveError_whenRemovingFilmFromWatched_handlesError(
        scenario: (systemError: Error,
                   expectedReason: PersistenceFailureReason)
    ) async throws {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: context, saver: saver)
        let targetFilm = Film.sample[0]
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: Persistence.entityname, in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        _ = PersistenceHelper.makeFilmMO(with: Film.sample[0], entity: entity, context: context, isUpNext: false, isWatched: true)
        try? context.save()
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: context,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        let expectedError = FilmDetailError.removeFailed(scenario.expectedReason)
        
        await sut.updateStatus(for: targetFilm, queue: .watched, action: .remove)
        
        #expect(sut.currentState == .error(expectedError, targetFilm, .watched), "Should be updated to error.")
        #expect(spy.didReceiveErrorCallCount == 1, "Should have called delegate method once on add failure.")
    }
    
    @Test("FRC delegate catches database film deletions, updates UI and calls delegates", .tags(.persistence))
    func filmDetailViewModel_frc_handlesDeletionFromDatabase_andUpdatesUI() throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: Persistence.entityname, in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        var targetFilm = Film.sample[0]
        targetFilm.isUpNext = true
        targetFilm.isWatched = true
        let filmMO = PersistenceHelper.makeFilmMO(
            with: targetFilm,
            entity: entity,
            context: context,
            isUpNext: true,
            isWatched: true
        )
        try? context.save()
        let sut = FilmDetailViewModel(imageLoader: MockImageLoader(),
                                      managedObjectContext: context,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        sut.film = targetFilm
        sut.setFilm()
        sut.performFetch()
        
        if case .content(let initialModel, _) = sut.currentState {
            #expect(initialModel.isUpNext == true, "Should be true.")
            #expect(initialModel.isWatched == true, "Should be true.")
        }
        
        filmMO.isUpNext = false
        filmMO.isWatched = false
        try? context.save()
        
        #expect(spy.upNextStatusChangeCallCount == 1, "Should have notified the delegate once.")
        #expect(spy.watchedStatusChangeCallCount == 1, "Should have notified the delegate once.")
        if case .content(let displayModel, _) = sut.currentState {
            #expect(displayModel.isUpNext == false, "Should be false.")
            #expect(displayModel.isWatched == false, "Should be false.")
        }
    }

    @Test("FRC delegate catches database edits from other tabs to keep the UI in sync and call delegate", .tags(.persistence))
    func filmDetailViewModel_frc_capturesExternalDatabaseSave_andUpdatesUI() throws {
        let targetFilm = Film.sample[0]
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let entity = try #require(
            NSEntityDescription.entity(forEntityName: Persistence.entityname, in: context),
            "The Core Data model schema must contain an entity definition named 'FilmMO'."
        )
        let filmMO = PersistenceHelper.makeFilmMO(
            with: targetFilm,
            entity: entity,
            context: context,
            isUpNext: true,
            isWatched: false
        )
        try? context.save()
        
        let sut = FilmDetailViewModel(imageLoader: MockImageLoader(),
                                      managedObjectContext: context,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        sut.film = targetFilm
        sut.setFilm()
        sut.performFetch()

        filmMO.isWatched = true
        try? context.save()

        #expect(spy.watchedStatusChangeCallCount == 1, "Should have notified the delegate once.")
        
        if case .content(let displayModel, _) = sut.currentState {
            #expect(displayModel.isWatched == true, "Should align with the fresh database record.")
        }
    }
    
    @Test("View model loads film content again")
    func filmDetailViewModel_returnToFilmContent_loadsFilmContentAgain() {
        let film = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let spy = FilmDetailViewModelSpy()
        sut.delegate = spy
        sut.film = film
        sut.setFilm()
        sut.performFetch()
        
        sut.returnToFilmContent()
        
        switch sut.currentState {
        case .noFilmSelected:
            Issue.record("Expected state to be `.content`, but it was `.noFilmSelected`.")
        case .content(let displayModel, _):
            #expect(displayModel.title == film.title, "Should match.")
            #expect(displayModel.visualOriginalTitles == "\(film.originalTitle)\n\(film.originalTitleRomanised)", "Should match.")
        case .fetchFailure:
            Issue.record("Expected state to be `.content`, but it was `.fetchFailure`.")
        case .error(_, _, _):
            Issue.record("Expected state to be `.content`, but it was `.error`.")
        }
        #expect(sut.filmWasUpdated == false, "Should be false.")
        #expect(spy.updateFilmDetailsCallCount == 2, "Should have been called twice; once for the loading content the first time, twice for loading it again.")
    }
    
    //MARK: - Helper methods
    private func makeSUT() -> FilmDetailViewModel {
        let persistenceController = try! PersistenceController.init(inMemory: true)
        let filmQueueService = FilmQueueService(context: persistenceController.viewContext)
        return FilmDetailViewModel(
            imageLoader: ExploreDetailMovieBannerMockImageLoader(),
            managedObjectContext: persistenceController.viewContext,
            frcFactory: MockFRCFactory(),
            filmQueueService: filmQueueService
        )
    }
    
    private func makeSUTAndContext() -> (
        sut: FilmDetailViewModel,
        context: NSManagedObjectContext
    ) {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        let sut = FilmDetailViewModel(
            imageLoader: ExploreDetailMovieBannerMockImageLoader(),
            managedObjectContext: context,
            frcFactory: MockFRCFactory(),
            filmQueueService: filmQueueService)
        return (sut, context)
    }
    
    private func makeSUTWithThrowingFRC(error: Error) -> FilmDetailViewModel {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        var mockFactory = MockFRCFactory()
        mockFactory.makeFilmDetailFRCStub = { _, context in
            return ThrowingFetchedResultsController(context: context, errorToThrow: error)
        }
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        return FilmDetailViewModel(
            imageLoader: mockImageLoader,
            managedObjectContext: context,
            frcFactory: mockFactory,
            filmQueueService: filmQueueService
        )
    }
    
    private func makeSUTAndMockImageLoader() -> (
        sut: FilmDetailViewModel,
        mockImageLoader: ExploreDetailMovieBannerMockImageLoader
    ) {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let sut = FilmDetailViewModel(imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService
        )
        return (sut, mockImageLoader)
    }
    
    //MARK: - Film Detail View Model Spy
    final class FilmDetailViewModelSpy: FilmDetailViewModelDelegate {
        var updateFilmDetailsCallCount = 0
        var updateWithEmptyStateCallCount = 0
        var upNextStatusChangeCallCount = 0
        var watchedStatusChangeCallCount = 0
        var didReceiveErrorCallCount: Int = 0
        
        func didUpdateFilmDetails() {
            updateFilmDetailsCallCount += 1
        }
        
        func didUpdateWithEmptyState() {
            updateWithEmptyStateCallCount += 1
        }
        
        func didUpdateUpNextStatus(isUpNext: Bool) {
            upNextStatusChangeCallCount += 1
        }
        
        func didUpdateWatchedStatus(isWatched: Bool) {
            watchedStatusChangeCallCount += 1
        }
        
        func didReceiveError() {
            didReceiveErrorCallCount += 1
        }
    }
}
