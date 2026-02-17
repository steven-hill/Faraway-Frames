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
        let cacheManager = MockCacheManager()
        let testImage = makeTestImage()
        let testURL = makeTestURL()
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://ghibliapi.vercel.app")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let session = StubNetworkSession(data: testImage.pngData()!, response: mockResponse)
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        let loadedImage = await sut.loadImage(from: testURL)
        
        #expect(loadedImage != nil, "Should not be nil.")
        #expect(cacheManager.setDataCalled == true, "Should be true.")
    }
    
    @Test func apiClientImageLoader_shouldRetrieveImageFromCache_ifItExists() async {
        let session = StubNetworkSession()
        let cacheManager = MockCacheManager()
        let urlString = makeURLString()
        let testImage = makeTestImage()
        let testURL = makeTestURL()
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        cacheManager.setData(testImage, forKey: urlString as NSString)
        let retrievedImage = await sut.loadImage(from: testURL)
        
        #expect(retrievedImage == testImage, "The retrieved image should be the one that was cached previously.")
        #expect(cacheManager.getDataCalled == true, "Should be true.")
        #expect(cacheManager.cachedData.keys.first == "https://example.com/image.png", "Cache should have stored the correct key.")
    }
    
    // MARK: - Helper methods
    private func makeURLString() -> String {
        "https://example.com/image.png"
    }
    
    private func makeTestImage() -> UIImage {
        UIImage(systemName: "popcorn")!
    }
    
    private func makeTestURL() -> URL {
        URL(string: makeURLString())!
    }
}
