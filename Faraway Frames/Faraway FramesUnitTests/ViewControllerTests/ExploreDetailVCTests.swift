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
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_contentUnavailableConfiguration_isNil() {
        let sut = makeSUTWhenFilmIsNil()
        
        sut.loadViewIfNeeded()
        sut.setNeedsUpdateContentUnavailableConfiguration()
        
        #expect(sut.contentUnavailableConfiguration == nil, "Should be nil.")
    }
    
    @Test func exploreDetailVC_viewDidLoad_whenFilmIsNil_displaysEmptyState() {
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
               expectedReason: FilmDetailError.FailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                      imageLoader: mockImageLoader,
                                      filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        let expectedError = FilmDetailError.addFailed(scenario.expectedReason)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)

        sut.didReceiveError()
        sut.view.layoutIfNeeded()

        #expect(sut.filmDetailViewModel.currentState == .error(expectedError, targetFilm, .upNext), "Should be in the error state.")
        #expect(sut.contentUnavailableConfiguration != nil, "Should not be nil.")
    }
    
    @Test("VC creates configuration for the error state",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_createErrorConfig_createsConfiguration(
    scenario: (systemError: Error,
               expectedReason: FilmDetailError.FailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                      imageLoader: mockImageLoader,
                                      filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)

        sut.didReceiveError()
        sut.view.layoutIfNeeded()
        
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        
        #expect(config != nil, "Should not be nil.")
        #expect(config?.button.title != nil, "Should have a title.")
        #expect(config?.secondaryButton.title != nil, "Should have a title.")
    }
    
    @Test("Tapping `Retry` button on error config calls VM's updateStatus method again and sets `attemptingUpdate` flag to true",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_tapRetryButtonOnErrorConfig_callsVMUpdateStatusAgain(
    scenario: (systemError: Error,
               expectedReason: FilmDetailError.FailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                      imageLoader: mockImageLoader,
                                      filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        sut.filmDetailViewModel.setFilm(targetFilm)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        sut.didReceiveError()
        sut.view.layoutIfNeeded()
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        
        config?.buttonProperties.primaryAction?.performWithSender(nil, target: nil)

        #expect(vm.attemptingToUpdateFilm == true, "Should be true because `updateStatus` was called from the retry button.")
    }
    
    @Test("Tapping `cancel` button on error config reloads film content and updates VM's `currentState`",
          .tags(.persistence),
          arguments: PersistenceHelper.errorScenarios
    )
    func exploreDetailVC_tapCancelButtonOnErrorConfig_reloadsFilmContentAndUpdatesState(
    scenario: (systemError: Error,
               expectedReason: FilmDetailError.FailureReason)
    ) async {
        let mockImageLoader = ExploreDetailMovieBannerMockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let saver = ThrowingSaver(errorToThrow: scenario.systemError)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext, saver: saver)
        let targetFilm = Film.sample[0]
        let vm = FilmDetailViewModel(film: targetFilm,
                                      imageLoader: mockImageLoader,
                                      filmQueueService: filmQueueService)
        let displayModel = FilmDetailViewModel.FilmDetailDisplayModel(film: targetFilm)
        let sut = ExploreDetailVC(filmDetailViewModel: vm)
        sut.filmDetailViewModel.setFilm(targetFilm)
        await sut.filmDetailViewModel.updateStatus(for: targetFilm, queue: .upNext, action: .add)
        sut.didReceiveError()
        sut.view.layoutIfNeeded()        
        let state = UIContentUnavailableConfigurationState(traitCollection: sut.traitCollection)
        sut.updateContentUnavailableConfiguration(using: state)
        let config = sut.contentUnavailableConfiguration as? UIContentUnavailableConfiguration
        
        config?.secondaryButtonProperties.primaryAction?.performWithSender(nil, target: nil)
        sut.view.layoutIfNeeded()
        
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
    
    @Test("Tapping upNextButton invokes the view model with the correct parameters", .tags(.persistence))
    func exploreDetailVC_upNextButtonTap_callsViewModelUpdateStatus() async {
        let (sut, spyVM) = makeSUTWithFilmAndSpyVM()
        
        sut.upNextButton.sendActions(for: .touchUpInside)
        await Task.yield()
        
        #expect(spyVM.updateStatusCallCount == 1, "Should have called the method once.")
        #expect(spyVM.capturedQueue == .upNext, "Should be the upNext queue.")
        #expect(spyVM.capturedAction == .add, "Action should be add.")
    }
    
    @Test("Tapping watchedButton invokes the view model with the correct parameters", .tags(.persistence))
    func exploreDetailVC_watchedButtonTap_callsViewModelUpdateStatus() async {
        let (sut, spyVM) = makeSUTWithFilmAndSpyVM()
        
        sut.watchedButton.sendActions(for: .touchUpInside)
        await Task.yield()
        
        #expect(spyVM.updateStatusCallCount == 1, "Should have called the method once.")
        #expect(spyVM.capturedQueue == .watched, "Should be the watched queue.")
        #expect(spyVM.capturedAction == .add, "Action should be add.")
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
        let filmDetailViewModel = FilmDetailViewModel(imageLoader: mockImageLoader, filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
    
    private func makeSUTWithFilm() -> ExploreDetailVC {
        let film = Film.sample[0]
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let filmDetailViewModel = FilmDetailViewModel(film: film, imageLoader: mockImageLoader, filmQueueService: filmQueueService)
        let sut = ExploreDetailVC(filmDetailViewModel: filmDetailViewModel)
        return sut
    }
    
    private func makeSUTWithFilmAndSpyVM() -> (vc: ExploreDetailVC, vm: FilmDetailViewModelSpy) {
        let film = Film.sample[0]
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
        let spyVM = FilmDetailViewModelSpy(
            film: film,
            imageLoader: MockImageLoader(),
            filmQueueService: filmQueueService
        )
        let vc = ExploreDetailVC(filmDetailViewModel: spyVM)
        _ = vc.view
        return (vc, spyVM)
    }
    
    //MARK: - Film Detail View Model Spy
    @MainActor
    private final class FilmDetailViewModelSpy: FilmDetailViewModel {
        var updateStatusCallCount = 0
        var capturedFilm: Film?
        var capturedQueue: FilmQueue?
        var capturedAction: QueueAction?

        override func updateStatus(for film: Film, queue: FilmQueue, action: QueueAction) async {
            updateStatusCallCount += 1
            capturedFilm = film
            capturedQueue = queue
            capturedAction = action
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

//MARK: - Extension on UIView
private extension UIView {
    func findView(withIdentifier identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier {
            return self
        }
        for subview in subviews {
            if let foundView = subview.findView(withIdentifier: identifier) {
                return foundView
            }
        }
        return nil
    }
}
