//
//  PersistenceControllerTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 28/05/2026.
//

import Testing
import CoreData
@testable import Faraway_Frames

@MainActor
struct PersistenceControllerTests {
    
    @Test("Invalid persistent container name string throws a loading failure", (.tags(.persistence)))
    func persistenceController_withTypoInContainerName_throwsLoadingStoresFailedError() throws {
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true, containerName: "FarawayFramesCDModelTypo")
        }
        
        switch thrownError {
        case .loadingStoresFailed(let error):
            let nsError = error as NSError
            #expect(nsError.domain == NSCocoaErrorDomain, "Should be a Cocoa error")
            #expect(nsError.code == NSFileReadNoSuchFileError, "Should be a no such file error")
        default:
            Issue.record("Expected .loadingStoresFailed, but got \(thrownError)")
        }
    }
    
    @Test("Error is thrown when loading persistent stores fails", (.tags(.persistence)))
    func persistenceController_whenLoadingPersistentStoresFails_throwsCorrectError() throws {
        let mockError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        
        let thrownError = #expect(throws: PersistenceError.self) {
            try PersistenceController(inMemory: true) { container, completion in
                completion(NSPersistentStoreDescription(), mockError)
            }
        }
        
        #expect(thrownError == .loadingStoresFailed(error: mockError))
    }
}
