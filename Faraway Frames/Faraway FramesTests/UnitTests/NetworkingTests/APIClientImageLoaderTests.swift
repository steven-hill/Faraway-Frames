//
//  APIClientImageLoaderTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 25/01/2026.
//

import Testing
@testable import Faraway_Frames
import UIKit

@MainActor
struct APIClientImageLoaderTests {
    
    @Test func apiClientImageLoader_whenSuccessful_shouldSaveImageToCache() async {
        let session = MockSession.createMockSession()
        let cacheManager = MockCacheManager()
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        let urlString = "https://example.com/image.png"
        let testImage = UIImage(systemName: "popcorn")!
        let testURL = URL(string: urlString)!
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == urlString)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, testImage.pngData()!)
        }
        
        let loadedImage = await sut.loadImage(from: testURL)
        
        #expect(loadedImage != nil, "Should not be nil.")
        #expect(cacheManager.setDataCalled == true, "Should be true.")
    }
    
    @Test func apiClientImageLoader_shouldRetrieveImageFromCache_ifItExists() async {
        let session = MockSession.createMockSession()
        let cacheManager = MockCacheManager()
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        let urlString = "https://example.com/image.png"
        let testImage = UIImage(systemName: "popcorn")!
        let testURL = URL(string: urlString)!
        
        cacheManager.setData(testImage, forKey: urlString as NSString)
        let retrievedImage = await sut.loadImage(from: testURL)
        
        #expect(retrievedImage == testImage, "The retrieved image should be the one that was cached previously.")
        #expect(cacheManager.getDataCalled == true, "Should be true.")
        #expect(cacheManager.cachedData.keys.first == "https://example.com/image.png", "Cache should have stored the correct key")
    }
}
