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
        self.session = session ?? URLSession(configuration: config)
        self.cacheManager = cacheManager
    }
    
    func loadImage(for image: String) async -> UIImage? {
        if let cachedImage = checkCache(for: image) {
            return cachedImage
        }
        
        do {
            guard let url = URL(string: image) else { return nil }
            let key = url.absoluteString as NSString
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cacheManager.setData(image, forKey: key)
            return image
        } catch {
            return nil
        }
    }
    
    func checkCache(for image: String) -> UIImage? {
        guard let url = URL(string: image) else { return nil }
        let key = url.absoluteString as NSString
        if let imageInNSCache = cacheManager.getData(forKey: key) {
            return imageInNSCache
        }
        
        let request = URLRequest(url: url)
        if let cachedResponse = session.configuration.urlCache?.cachedResponse(for: request),
           let imageInURLCache = UIImage(data: cachedResponse.data) {
            cacheManager.setData(imageInURLCache, forKey: key)
            return imageInURLCache
        } else {
            return nil
        }
    }
}
