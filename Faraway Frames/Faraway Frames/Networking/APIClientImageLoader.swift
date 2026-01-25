//
//  APIClientImageLoader.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/01/2026.
//

import UIKit

final class APIClientImageLoader: ImageLoader {
    private let session: URLSession
    private let cacheManager: CacheManagerProtocol
    
    init(session: URLSession = .shared, cacheManager: CacheManagerProtocol) {
        self.session = session
        self.cacheManager = cacheManager
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        let image: UIImage?
        let key = url.absoluteString as NSString
        if let cachedImage = cacheManager.getData(forKey: key) {
            return cachedImage
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
