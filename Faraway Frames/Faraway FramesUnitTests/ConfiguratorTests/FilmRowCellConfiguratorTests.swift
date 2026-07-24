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
        
        #expect(spy.configureTitleCalledCallCount == 1, "Should have called configureTitle once.")
        #expect(spy.lastConfiguredTitle == film.title, "Should match the film title.")
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
