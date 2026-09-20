//
//  MockCacheManager.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 25/01/2026.
//

import Foundation
@testable import Faraway_Frames
import UIKit

final class MockCacheManager: CacheManagerProtocol {
    var cachedData: [NSString: UIImage] = [:]
    private(set) var setDataCallCount = 0
    private(set) var getDataCallCount = 0
    
    func setData(_ data: UIImage, forKey key: NSString) {
        setDataCallCount += 1
        cachedData[key] = data
    }
    
    func getData(forKey key: NSString) -> UIImage? {
        getDataCallCount += 1
        return cachedData[key]
    }
}
