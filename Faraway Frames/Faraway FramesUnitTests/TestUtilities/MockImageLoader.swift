//
//  MockImageLoader.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/01/2026.
//

import Foundation
import UIKit
@testable import Faraway_Frames

final class MockImageLoader: ImageLoader {
    var shouldSucceed: Bool = true
    private(set) var checkCacheCallCount = 0
    private var mockCache: [String: UIImage] = [:]
    private var currentLoadingKey: String?
    
    func loadImage(for image: String) async -> UIImage? {
        currentLoadingKey = image
        let image: UIImage?
        if shouldSucceed {
            image = SFSymbols.popcorn
            if let key = currentLoadingKey {
                mockCache[key] = image
            }
        } else {
            return nil
        }
        return image
    }
    
    func checkCache(for image: String) -> UIImage? {
        checkCacheCallCount += 1
        return mockCache[image]
    }
}
