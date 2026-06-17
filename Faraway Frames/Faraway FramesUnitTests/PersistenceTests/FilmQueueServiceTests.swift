//
//  FilmQueueServiceTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/06/2026.
//

import Testing
@testable import Faraway_Frames

@MainActor
struct FilmQueueServiceTests {

    @Test("Early exit if trying to remove an entry that doesn't exist in database")
    func filmQueueService_updateFilmStatus_existsEarlyIfFilmDoesNotExistInDatabase() async throws {
        let testPersistenceController = try! PersistenceController(inMemory: true)
        let sut = FilmQueueService(context: testPersistenceController.viewContext)
        let film = Film.sample[0]
        let result = try await sut.updateFilmStatus(film: film, queue: .upNext, action: .remove)
        
        #expect(result == false, "Should be false when trying to remove a film that doesn't exist in the database.")
    }
}
