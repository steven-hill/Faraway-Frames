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
    var setDataCalled = false
    var getDataCalled = false
    
    func setData(_ data: UIImage, forKey key: NSString) {
        setDataCalled = true
        cachedData[key] = data
    }
    
    func getData(forKey key: NSString) -> UIImage? {
        getDataCalled = true
        return cachedData[key]
    }
}
