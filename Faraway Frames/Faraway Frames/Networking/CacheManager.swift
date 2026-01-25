//
//  CacheManager.swift
//  Faraway Frames
//
//  Created by Steven Hill on 25/01/2026.
//

import UIKit

final class CacheManager: CacheManagerProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    func getData(forKey key: NSString) -> UIImage? {
        cache.object(forKey: key)
    }
    
    func setData(_ image: UIImage, forKey key: NSString) {
        cache.setObject(image, forKey: key)
    }
}

