//
//  ExploreListVCTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 18/01/2026.
//

import Testing
import UIKit
@testable import Faraway_Frames

@MainActor
struct ExploreListVCTests {

    @Test func exploreListVC_canInit() {
        let mockFilmsListService = MockFilmsListService()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)
        let vc = ExploreListVC(viewModel: filmsListViewModel)
        let _ = UINavigationController(rootViewController: vc)

        vc.loadViewIfNeeded()
        
        #expect((vc.navigationController != nil), "VC should be inside a navigation controller.")
    }
    
    @Test func exploreListVC_canUpdateFilmsArraySuccessfully() async throws {
        let mockFilmsListService = setupMockServiceForSuccessCase()
        let imageLoader = MockImageLoader()
        let filmsListViewModel = FilmsListViewModel(filmsListService: mockFilmsListService, imageLoader: imageLoader)

        let vc = ExploreListVC(viewModel: filmsListViewModel)
        
        vc.loadViewIfNeeded()
        try await Task.sleep(nanoseconds: 100)
        
        #expect(vc.films.count == 22, "VC's film should contain 22 films.")
    }
    
    // MARK: - Helper method
    private func setupMockServiceForSuccessCase() -> MockFilmsListService {
        var mockService = MockFilmsListService()
        let films = try! loadAndDecodeFilmsFromJSON()
        mockService.result = .success(films)
        return mockService
    }
    
    private func loadAndDecodeFilmsFromJSON() throws -> [Film] {
        guard let bundle = Bundle(identifier: "com.StevenHill.Faraway-FramesTests"),
              let url = bundle.url(forResource: "ghibliFilms", withExtension: "json") else {
            Issue.record("ghibliFilms JSON file not found")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Film].self, from: data)
        } catch {
            Issue.record("ghibliFilms JSON file decoding failed with error: \(error)")
            return []
        }
    }
}
