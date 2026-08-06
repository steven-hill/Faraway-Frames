//
//  ExploreDetailVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 05/02/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit
import CoreData

@MainActor
struct ExploreDetailVCTests {
    
    @Test func exploreDetailVC_whenFilmIsNil_localStatePropertiesAreSetCorrectly() {
        let sut = makeSUTWhenFilmIsNil()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.isUpNext == false, "Should be false.")
        #expect(sut.isWatched == false, "Should be false.")
        #expect(sut.updatedFilm == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_withFilm_localStatePropertiesAreSetCorrectly() {
        let sut = makeSUTWithFilm()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.isUpNext == false, "Should be false.")
        #expect(sut.isWatched == false, "Should be false.")
        #expect(sut.updatedFilm == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_whenFilmIsNil_isInsideANavigationController() {
        let sut = makeSUTWhenFilmIsNil()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_withFilm_isInsideANavigationController() {
        let sut = makeSUTWithFilm()
        _ = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        
        #expect(sut.navigationController != nil, "VC should be inside a navigation controller.")
    }
    
    @Test func exploreDetailVC_whenFilmIsNil_canLoadView() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func exploreDetailVC_withFilm_canLoadView() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.view != nil, "VC should load the view.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_setsDelegate() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.filmDetailViewModel.delegate != nil, "Should set the delegate.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_withFilm_setsDelegate() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        
        #expect(sut.filmDetailViewModel.delegate != nil, "Should set the delegate.")
    }

    @Test func exploreDetailVC_viewDidLoad_withFilm_contentUnavailableConfiguration_isNil() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_displaysEmptyState_andContentUnavailableConfiguration_isNil() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_navigationBarTitle_isNil() {
        let sut = makeSUTWhenFilmIsNil()

        sut.loadViewIfNeeded()
    
        #expect(sut.title == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_withFilm_navigationBarTitle_isNil() {
        let sut = makeSUTWithFilm()

        sut.loadViewIfNeeded()
    
        #expect(sut.title == nil, "Should be nil.")
    }
    
    @Test("Alert is presented for fetch film failure",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_whenPerformFetchFailsOnViewModel_presentsAlert(
        scenario: (systemError: CocoaError,
                   expectedReason: PersistenceFailureReason)
    ) async throws {
        let sut = try makeSUTWithFetchFailureFRC(throwing: scenario.systemError)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        
        sut.filmDetailViewModel.setFilm(Film.sample[0])
        
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        let expectedError = FilmDetailError.fetchFailed(scenario.expectedReason)
        
        #expect(config == nil, "Should be nil.")
        #expect(mockPresenter.capturedTitle == expectedError.localizedDescription, "Should match the expected error passed in.")
        #expect(mockPresenter.capturedMessage == scenario.expectedReason.message, "Should match the expected reason passed in.")
        #expect(mockPresenter.capturedActions.count == 1, "Should have one.")
    }
    
    @Test("Fetch failure alert handles an unknown error gracefully by displaying its description", .tags(.persistence))
    func exploreDetailVC_whenUnknownErrorOccursInFetchFailure_presentsAlert() async throws {
        let unknownError = UnknownError()
        let sut = try makeSUTWithFetchFailureFRC(throwing: unknownError)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        
        sut.filmDetailViewModel.setFilm(Film.sample[0])
        
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        let expectedError = FilmDetailError.fetchFailed(.unknown(unknownError.localizedDescription))
        let expectedReason = PersistenceFailureReason.unknown(unknownError.localizedDescription)
        
        #expect(config == nil, "Should be nil.")
        #expect(mockPresenter.capturedTitle == expectedError.localizedDescription, "Should match the expected error passed in.")
        #expect(mockPresenter.capturedMessage == expectedReason.message, "Should match the expected reason passed in.")
        #expect(mockPresenter.capturedActions.count == 1, "Should have one.")
    }

    @Test("Tapping `Ok` button on fetch failure alert reloads film content and updates VM's `currentState`",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_tapOkButtonOnFetchFailureAlert_reloadsFilmContentAndUpdatesState(
        scenario: (systemError: CocoaError,
                   expectedReason: PersistenceFailureReason)
    ) async throws {
        let film = Film.sample[0]
        let sut = try makeSUTWithFetchFailureFRC(throwing: scenario.systemError)
        sut.filmDetailViewModel.setFilm(film)
        sut.view.layoutIfNeeded()
        
        // Simulates tapping 'Ok' button.
        sut.filmDetailViewModel.returnToFilmContent(film: film)
        
        switch sut.filmDetailViewModel.currentState {
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
    }
    
    @Test func exploreDetailVC_didUpdateFilmDetails_notifiesContentUnavailableConfigurationToUpdateAndSetsUpdatedFilm() {
        let sut = makeSUTWithFilm()
        sut.loadViewIfNeeded()
        
        sut.didUpdateFilmDetails()
        sut.view.layoutIfNeeded()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
        #expect(sut.updatedFilm != nil, "Should not be nil.")
    }
    
    @Test func exploreDetailVC_didUpdateWithEmptyState_notifiesContentUnavailableConfigurationToUpdateAndUpdatedFilmIsStillNil() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.didUpdateWithEmptyState()
        sut.view.layoutIfNeeded()
        
        #expect(sut.filmDetailViewModel.currentState == .noFilmSelected, "Should be `.noFilmSelected`.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
        #expect(sut.updatedFilm == nil, "Should be nil.")
    }
    
    @Test("`didUpdateUpNextStatus` flips VC's isUpNext state property to true", .tags(.persistence))
    func exploreDetailVC_didUpdateUpNextStatus_flipsUpNextStatePropertyToTrue() {
        let sut = makeSUTWithFilm()
        
        sut.didUpdateUpNextStatus(isUpNext: true)
        
        #expect(sut.isUpNext == true, "Should be true.")
    }
    
    @Test("`didUpdateUpNextStatus` flips VC's isUpNext state property to false", .tags(.persistence))
    func exploreDetailVC_didUpdateUpNextStatus_flipsUpNextStatePropertyToFalse() {
        let sut = makeSUTWithFilm()
        
        sut.didUpdateUpNextStatus(isUpNext: false)
        
        #expect(sut.isUpNext == false, "Should be false.")
    }
    
    @Test("`didUpdateWatchedStatus` flips VC's isWatched state property to true", .tags(.persistence))
    func exploreDetailVC_didUpdateWatchedStatus_isWatchedStatePropertyChangedToTrue() {
        let sut = makeSUTWithFilm()
        
        sut.didUpdateWatchedStatus(isWatched: true)
        
        #expect(sut.isWatched == true, "Should be true.")
    }
    
    @Test("`didUpdateWatchedStatus` flips VC's isWatched state property to false", .tags(.persistence))
    func exploreDetailVC_didUpdateWatchedStatus_isWatchedStatePropertyChangedToFalse() {
        let sut = makeSUTWithFilm()
        
        sut.didUpdateWatchedStatus(isWatched: false)
        
        #expect(sut.isWatched == false, "Should be false.")
    }
    
    @Test("VC requests that the system update the content-unavailable configuration for the error state",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_didReceiveError_notifiesContentUnavailableConfigurationToUpdate(
    scenario: (systemError: Error,
               expectedReason: PersistenceFailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                     imageLoader: mockImageLoader,
                                     managedObjectContext: testPersistenceController.viewContext,
                                     frcFactory: MockFRCFactory(),
                                     filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        let expectedError = FilmDetailError.addFailed(scenario.expectedReason)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)

        sut.didReceiveError()
        sut.view.layoutIfNeeded()

        #expect(sut.filmDetailViewModel.currentState == .error(expectedError, targetFilm, .upNext), "Should be in the error state.")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test("VC presents alert when there is an error adding or removing a film",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_whenUpdatingStateFails_presentsAlert(
    scenario: (systemError: CocoaError,
               expectedReason: PersistenceFailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                     imageLoader: mockImageLoader,
                                     managedObjectContext: testPersistenceController.viewContext,
                                     frcFactory: MockFRCFactory(),
                                     filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        await sut.filmDetailViewModel.updateStatus(for: targetFilm,
                                                   queue: .upNext,
                                                   action: .add)

        sut.didReceiveError()
        sut.view.layoutIfNeeded()
        let expectedError = FilmDetailError.addFailed(scenario.expectedReason)
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        
        #expect(config == nil, "Should not be nil.")
        #expect(mockPresenter.capturedTitle == expectedError.localizedDescription, "Should match the expected error passed in.")
        #expect(mockPresenter.capturedMessage == scenario.expectedReason.message, "Should match the expected reason passed in.")
        #expect(mockPresenter.capturedActions.count == 2, "Should have two.")
    }
    
    @Test("Tapping `Retry` button on alert calls VM's `updateStatus` method again and sets `attemptingUpdate` flag to true",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_tapRetryButtonOnErrorConfig_callsVMUpdateStatusAgain(
    scenario: (systemError: Error,
               expectedReason: PersistenceFailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                      imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        sut.filmDetailViewModel.setFilm(targetFilm)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        sut.didReceiveError()
        sut.view.layoutIfNeeded()
        
        guard let retryAction = mockPresenter.capturedActions.first(where: { $0.title == "Retry" }) else {
            Issue.record("Retry action was not configured on the alert")
            return
        }
        retryAction.handler?(retryAction)
        
        #expect(vm.attemptingToUpdateFilm == true, "Should be true because `updateStatus` was called from the retry button.")
    }
    
    @Test("Tapping `cancel` button on error config reloads film content and updates VM's `currentState`",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_tapCancelButtonOnErrorConfig_reloadsFilmContentAndUpdatesState(
    scenario: (systemError: Error,
               expectedReason: PersistenceFailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                      imageLoader: mockImageLoader,
                                      managedObjectContext: testPersistenceController.viewContext,
                                      frcFactory: MockFRCFactory(),
                                      filmQueueService: filmQueueService)
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: targetFilm)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        let mockPresenter = MockAlertPresenter()
        sut.alertPresenter = mockPresenter
        sut.filmDetailViewModel.setFilm(targetFilm)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        sut.didReceiveError()
        sut.view.layoutIfNeeded()        

        guard let cancelAction = mockPresenter.capturedActions.first(where: { $0.title == "Cancel" }) else {
            Issue.record("Cancel action was not configured on the alert")
            return
        }
        cancelAction.handler?(cancelAction)
        
        #expect(sut.upNextButton.isEnabled == true, "Button should be enabled again.")
        #expect(vm.currentState == .content(displayModel: displayModel, image: nil), "Should have returned to content state (note: image is nil because mockImageLoader didn't load image in test setup).")
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil because VC is displaying film content again.")
        #expect(sut.filmDetailViewModel.filmWasUpdated == false, "Should be false because update status failed.")
    }
    
    @Test("Integration test to check that the label successfully receives the text from ViewModel.")
    func exploreDetailVC_createContent_successfullyBindsAccessibilityPropertiesToLabel() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        let targetIdentifier = "ExploreDetailVC_OriginalTitlesLabel"
        let foundLabel = sut.view.findView(withIdentifier: targetIdentifier) as? UILabel        
        guard let label = foundLabel else {
            Issue.record("Could not find a UILabel with accessibilityIdentifier: '\(targetIdentifier)'.")
            return
        }
        
        let expectedPrefix = "Original title: "
        #expect(label.accessibilityAttributedLabel?.string == "\(expectedPrefix)\(Film.sample[0].originalTitle)")
    }
    
    @Test func exploreDetailVC_whenFilmIsNil_buttonsContainerIsHidden() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        
        #expect(sut.view.findView(withIdentifier: "ExploreDetailVC_ButtonsContainer")?.isHidden == true,
                "Buttons container must be hidden when state is `.noFilmSelected`.")
    }
    
    @Test func exploreDetailVC_withFilm_buttonsContainerIsVisible() {
        let sut = makeSUTWithFilm()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        
        #expect(sut.view.findView(withIdentifier: "ExploreDetailVC_ButtonsContainer")?.isHidden == false,
                "Buttons container must be visible when state is `.content`.")
    }
    
    @Test("Tapping `upNextButton` invokes the view model's service method with the correct parameters", .tags(.persistence))
    func exploreDetailVC_upNextButtonTap_viaViewModel_callsServiceUpdateFilmStatus() async {
        let (sut, spyFQS) = makeSUTWithFilmAndFilmQueueServiceSpy()
        
        sut.upNextButton.sendActions(for: .touchUpInside)
        await Task.yield()
        
        #expect(spyFQS.updateFilmStatusCallCount == 1, "Should have called the method once.")
        #expect(spyFQS.capturedQueue == .upNext, "Should be the upNext queue.")
        #expect(spyFQS.capturedAction == .add, "Action should be add.")
    }
    
    @Test("Tapping `watchedButton` invokes the view model's service method with the correct parameters", .tags(.persistence))
    func exploreDetailVC_watchedButtonTap_viaViewModel_callsServiceUpdateFilmStatus() async {
        let (sut, spyFQS) = makeSUTWithFilmAndFilmQueueServiceSpy()
        
        sut.watchedButton.sendActions(for: .touchUpInside)
        await Task.yield()
        
        #expect(spyFQS.updateFilmStatusCallCount == 1, "Should have called the method once.")
        #expect(spyFQS.capturedQueue == .watched, "Should be the watched queue.")
        #expect(spyFQS.capturedAction == .add, "Action should be add.")
    }
    
    @Test("Tapping upNextButton disables the button while persistence operation is performed", .tags(.persistence))
    func exploreDetailVC_upNextButtonTap_disablesButtonTemporarily() async {
        let sut = makeSUTWithFilm()
        _ = sut.view
        
        sut.upNextButton.sendActions(for: .touchUpInside)
        await Task.yield()
        
        #expect(sut.upNextButton.isEnabled == false, "The button should be disabled.")
        #expect(sut.watchedButton.isEnabled == true, "The button should be enabled.")
        
        sut.didUpdateUpNextStatus(isUpNext: true)
        
        #expect(sut.upNextButton.isEnabled == true, "The button should be enabled.")
        #expect(sut.watchedButton.isEnabled == true, "The button should be enabled.")
    }
    
    @Test("Tapping watchedButton disables the button while persistence operation is performed", .tags(.persistence))
    func exploreDetailVC_watchedButtonTap_disablesButtonTemporarily() async {
        let sut = makeSUTWithFilm()
        _ = sut.view
        
        sut.watchedButton.sendActions(for: .touchUpInside)
        await Task.yield()
        
        #expect(sut.watchedButton.isEnabled == false, "The button should be disabled.")
        #expect(sut.upNextButton.isEnabled == true, "The button should be enabled.")
        
        sut.didUpdateWatchedStatus(isWatched: true)
        
        #expect(sut.watchedButton.isEnabled == true, "The button should be enabled.")
        #expect(sut.upNextButton.isEnabled == true, "The button should be enabled.")
    }
    
    @Test("`viewWillDisappear` calls delegate with the film when view model has changes", .tags(.persistence))
    func exploreDetailVC_viewWillDisappear_whenHasChangesIsTrue_notifiesDelegate() async {
        let sut = makeSUTWithFilm()
        let delegateSpy = FilmDetailViewControllerDelegateSpy()
        sut.delegate = delegateSpy
        await sut.filmDetailViewModel.updateStatus(for: Film.sample[0], queue: .upNext, action: .add)
        sut.updateContentUnavailableConfiguration(using: sut.contentUnavailableConfigurationState)
        
        sut.viewWillDisappear(false)
        
        #expect(sut.filmDetailViewModel.filmWasUpdated == true, "Should be true.")
        #expect(delegateSpy.didUpdateFilmCallCount == 1, "Delegate should be notified once when changes exist.")
        #expect(delegateSpy.capturedFilm?.id == Film.sample[0].id, "The updated film should match the film being shown in the view controller.")
        #expect(delegateSpy.capturedFilm?.isUpNext == true, "Should be true.")
    }
    
    @Test("`viewWillDisappear` silently exits when view model has no changes")
    func exploreDetailVC_viewWillDisappear_whenHasChangesIsFalse_doesNotNotifyDelegate() {
        let sut = makeSUTWithFilm()
        let delegateSpy = FilmDetailViewControllerDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.viewWillDisappear(false)
        
        #expect(delegateSpy.didUpdateFilmCallCount == 0, "Delegate must remain uncalled if no changes occurred.")
        #expect(delegateSpy.capturedFilm == nil, "Should be nil.")
    }
    
    //MARK: - SUT Helper Methods
    private func makeSUTWhenFilmIsNil() -> ExploreDetailVC {
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmDetailViewModel = FilmDetailViewModel(imageLoader: mockImageLoader,
                                                      managedObjectContext: testPersistenceController.viewContext,
                                                      frcFactory: MockFRCFactory(),
                                                      filmQueueService: filmQueueService,
                                                      )
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
    
    private func makeSUTWithFilm() -> ExploreDetailVC {
        let film = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmDetailViewModel = FilmDetailViewModel(film: film,
                                                      imageLoader: mockImageLoader,
                                                      managedObjectContext: testPersistenceController.viewContext,
                                                      frcFactory: MockFRCFactory(),
                                                      filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
    
    private func makeSUTWithFetchFailureFRC(throwing error: Error) throws -> ExploreDetailVC {
        let testPersistenceController = try PersistenceController(inMemory: true)
        let context = testPersistenceController.viewContext
        let filmQueueService = FilmQueueService(context: context)
        var mockFactory = MockFRCFactory()
        mockFactory.makeFilmDetailFRCStub = { _, context in
            return ThrowingFetchedResultsController(context: context, errorToThrow: error)
        }
        let mockImageLoader = MockImageLoader()
        let vm = FilmDetailViewModel(imageLoader: mockImageLoader,
                                     managedObjectContext: context,
                                     frcFactory: mockFactory,
                                     filmQueueService: filmQueueService)
        return ExploreDetailVC(filmDetailViewModel: vm)
    }
    
    private func makeSUTWithFilmAndFilmQueueServiceSpy() -> (vc: ExploreDetailVC, spyFQS: FilmQueueServiceSpy) {
        let film = Film.sample[0]
        let spyFQS = FilmQueueServiceSpy()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmDetailViewModel = FilmDetailViewModel(film: film,
                                                      imageLoader: MockImageLoader(),
                                                      managedObjectContext: testPersistenceController.viewContext,
                                                      frcFactory: MockFRCFactory(),
                                                      filmQueueService: spyFQS)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        sut.loadViewIfNeeded()
        return (sut, spyFQS)
    }
    
    //MARK: - Film Queue Service Spy
    private final class FilmQueueServiceSpy: FilmQueueServiceProtocol {
        var updateFilmStatusCallCount = 0
        var capturedFilm: Film?
        var capturedQueue: FilmQueue?
        var capturedAction: QueueAction?
        
        @discardableResult
        func updateFilmStatus(film: Film, queue: FilmQueue, action: QueueAction) async throws -> Bool {
            updateFilmStatusCallCount += 1
            capturedFilm = film
            capturedQueue = queue
            capturedAction = action
            
            return updateFilmStatusCallCount > 0 ? true : false
        }
    }
    
    //MARK: - Film Detail View Controller Delegate Spy
    private final class FilmDetailViewControllerDelegateSpy: FilmDetailViewControllerDelegate {
        var didUpdateFilmCallCount = 0
        var capturedFilm: Film?
        
        func filmDetailViewController(_ controller: ExploreDetailVC, didUpdateFilm updatedFilm: Film) {
            didUpdateFilmCallCount += 1
            capturedFilm = updatedFilm
        }
    }
}
