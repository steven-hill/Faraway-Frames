//
//  MockServiceHelper.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/02/2026.
//


import Foundation
import Testing
@testable import Faraway_Frames

struct MockServiceHelper {
    static func setupMockServiceForSuccessCase() -> MockFilmsListService {
        let mockService = MockFilmsListService()
        let films = try! JSONHelper.loadAndDecodeFilmsFromJSON() 
        mockService.result = .success(films)
        return mockService
    }
}