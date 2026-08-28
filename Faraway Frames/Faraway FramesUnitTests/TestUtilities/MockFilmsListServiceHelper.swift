//
//  MockServiceHelper.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/02/2026.
//


import Foundation
import Testing
@testable import Faraway_Frames

struct MockFilmsListServiceHelper {
    static func setupMockServiceForSuccessCase() -> MockFilmsListService {
        let mockService = MockFilmsListService()
        let films = try! JSONHelper.loadAndDecodeFilmsFromJSON() 
        mockService.result = .success(films)
        return mockService
    }
    
    static func setupMockServiceForFailureCase(error: Error) -> MockFilmsListService {
        let mockService = MockFilmsListService()
        mockService.result = .failure(error)
        return mockService
    }
}
