//
//  PersistenceControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 28/05/2026.
//

import Testing

struct PersistenceControllerTests {

    @Test func persistenceController_canInit() {
        let sut = PersistenceController(inMemory: true)
        #expect(sut.persistenceError == .none)
    }
}
