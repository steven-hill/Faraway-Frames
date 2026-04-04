//
//  APIClientImageLoader.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/01/2026.
//

import UIKit

final class APIClientImageLoader: ImageLoader {
    private let session: NetworkSession
    private let cacheManager: CacheManagerProtocol
    
    init(session: NetworkSession? = nil, cacheManager: CacheManagerProtocol) {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024, diskPath: "com.stevenhill.farawayframes.cache")
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        if let injectedSession = session {
            self.session = injectedSession
        } else {
            self.session = URLSession(configuration: config)
        }
        
        self.cacheManager = cacheManager
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        let image: UIImage?
        let key = url.absoluteString as NSString
        if let cachedImage = cacheManager.getData(forKey: key) {
            return cachedImage
        }
        
        let request = URLRequest(url: url)
        if let cachedResponse = session.configuration.urlCache?.cachedResponse(for: request),
        let imageFromURLCache = UIImage(data: cachedResponse.data) {
            cacheManager.setData(imageFromURLCache, forKey: key)
            return imageFromURLCache
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            image = UIImage(data: data)
            if let imageToBeCached = image {
                cacheManager.setData(imageToBeCached, forKey: key)
            }
        } catch {
            return nil
        }
        return image
    }
}
