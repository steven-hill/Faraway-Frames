//
//  FilmRowCellConfiguratorTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 24/07/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct FilmRowCellConfiguratorTests {
    
    @Test("Configuring a cell sets the title text")
    func filmRowCellConfigurator_configure_setsTitle() {
        let film = Film.sample[0]
        let spy = FilmRowCellSpy()
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService,
                                                    imageLoader: mockImageLoader,
                                                    filmSyncService: filmSyncService)
        let sut = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        
        sut.configure(spy, with: film)
        
        #expect(spy.configureTitleCalledCallCount == 1, "Should have called `configureTitle` once.")
        #expect(spy.lastConfiguredTitle == film.title, "Should match the film title.")
    }
    
    @Test("Configuring a cell schedules an async task that yields the correct image")
    func filmRowCellConfigurator_configure_fetchesImageAndUpdatesCell() async {
        let film = Film.sample[0]
        let spy = FilmRowCellSpy()
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService,
                                                    imageLoader: mockImageLoader,
                                                    filmSyncService: filmSyncService)
        let sut = FilmRowCellConfigurator(viewModel: filmsListViewModel)
        
        sut.configure(spy, with: film)
        
        guard let task = spy.imageTask else {
            Issue.record("An image task should have been assigned to the cell.")
            return
        }
        _ = await task.result
        
        #expect(spy.configureImageCalledCallCount == 1, "Should have called `configureImage` once.")
        #expect(spy.lastConfiguredImage == SFSymbols.popcorn, "Should have set the correct image (`SFSymbols.popcorn` is the image returned by `MockImageLoader` if download is successful).")
    }
    
    @Test("Configuring a reused cell cancels its previous image download task")
    func filmRowCellConfigurator_configure_cancelsPreviousTaskOnReuse() {
        let filmA = Film.sample[0]
        let filmB = Film.sample[1]
        let spy = FilmRowCellSpy()
        let mockService = MockFilmsListService()
        let mockImageLoader = MockImageLoader()
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let filmSyncService = FilmSyncService(context: testPersistenceController.viewContext)
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockService,
                                                    imageLoader: mockImageLoader,
                                                    filmSyncService: filmSyncService)
        let sut = FilmRowCellConfigurator(viewModel: filmsListViewModel)
                
        sut.configure(spy, with: filmA)
        let firstTask = spy.imageTask
        
        sut.configure(spy, with: filmB)
        let secondTask = spy.imageTask
        
        #expect(firstTask?.isCancelled == true, "The first cell task should have been cancelled.")
        #expect(secondTask?.isCancelled == false, "The second cell task should remain actively running.")
    }
    
    // MARK: - Spy Cell
    final class FilmRowCellSpy: FilmRowCellRepresentable {
        var imageTask: Task<Void, Never>?
        var configureTitleCalledCallCount = 0
        var configureImageCalledCallCount = 0
        var lastConfiguredTitle: String?
        var lastConfiguredImage: UIImage?
        
        func configureTitle(title: String) {
            configureTitleCalledCallCount += 1
            lastConfiguredTitle = title
        }
        
        func configureImage(image: UIImage?) {
            configureImageCalledCallCount += 1
            lastConfiguredImage = image
        }
    }
}
