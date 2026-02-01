//
//  MockContainer.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 01/02/2026.
//

import Foundation
@testable import Faraway_Frames

final class MockContainer: FilmsListServicing, ImageLoading {
    func makeFilmsListService() -> FilmsListService {
        return MockFilmsListService()
    }
    
    func makeImageLoader() -> ImageLoader {
        return MockImageLoader()
    }
}
