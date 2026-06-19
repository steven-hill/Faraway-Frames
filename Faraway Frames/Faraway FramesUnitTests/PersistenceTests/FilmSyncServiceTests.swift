//
//  FilmSyncServiceTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 19/06/2026.
//

import Testing
@testable import Faraway_Frames

struct FilmSyncServiceTests {

    @Test("Should exit immediately if input films array is empty")
    func filmSyncService_syncFilmsWithLocalStorage_ifFilmsArrayIsEmpty_exitsImmediately() async {
        let sut = FilmSyncService()
        let films: [Film] = []
        
        let result = await sut.syncFilmsWithLocalStorage(films)
        
        #expect(result.isEmpty, "Should be empty.")
    }
}
