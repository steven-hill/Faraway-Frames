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
    
    @Test(.tags(.networkRequest))
    func apiClientImageLoader_loadImage_whenSuccessful_shouldSaveImageToNSCache() async {
        let cacheManager = MockCacheManager()
        let testImage = makeTestImage()
        let urlString = makeURLString()
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://ghibliapi.vercel.app")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let session = StubNetworkSession(data: testImage.pngData()!, response: mockResponse)
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        let loadedImage = await sut.loadImage(for: urlString)
        
        #expect(loadedImage != nil, "Should not be nil.")
        #expect(cacheManager.setDataCalled == true, "Should be true.")
    }
    
    @Test(.tags(.networkRequest))
    func apiClientImageLoader_loadImage_ifThereIsAnError_shouldReturnNil() async {
        let cacheManager = MockCacheManager()
        let urlString = makeURLString()
        let session = StubNetworkSession(error: APIError.noInternetConnection)
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        let loadedImage = await sut.loadImage(for: urlString)
        
        #expect(loadedImage == nil, "Should be nil.")
        #expect(cacheManager.setDataCalled == false, "Should be false.")
    }
    
    @Test func apiClientImageLoader_ifImageExistsInNSCache_shouldRetrieveImageFromNSCache() async {
        let session = StubNetworkSession()
        let cacheManager = MockCacheManager()
        let urlString = makeURLString()
        let testImage = makeTestImage()
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        cacheManager.setData(testImage, forKey: urlString as NSString)
        let retrievedImage = await sut.loadImage(for: urlString)
        
        #expect(retrievedImage == testImage, "The retrieved image should be the one that was cached previously.")
        #expect(cacheManager.getDataCalled == true, "Should be true.")
        #expect(cacheManager.cachedData.keys.first == "https://example.com/image.png", "Cache should have stored the correct key.")
    }
    
    @Test func apiClientImageLoader_whenImageIsInURLCacheButNotNSCache_shouldRetrieveFromURLCacheAndAddToNSCache() async {
        let cacheManager = MockCacheManager()
        let testURL = makeTestURL()
        let urlString = makeURLString()
        let testImage = makeTestImage()
        let imageData = testImage.pngData()!
        
        let mockResponse = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
                
        let testCache = URLCache(memoryCapacity: 10 * 1024, diskCapacity: 10 * 1024, diskPath: "test_URLCache")
        let cachedResponse = CachedURLResponse(response: mockResponse, data: imageData)
        testCache.removeAllCachedResponses()
        testCache.storeCachedResponse(cachedResponse, for: URLRequest(url: testURL))
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = testCache
        let session = StubNetworkSession(configuration: configuration)
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        let retrievedImage = await sut.loadImage(for: urlString)
        
        #expect(cacheManager.getDataCalled == true, "Should have checked NSCache first.")
        #expect(retrievedImage != nil, "Should have retrieved image from URLCache.")
        #expect(cacheManager.setDataCalled == true, "Should have saved the URLCache result back into NSCache for next time.")
    }
    
    @Test func apiClientImageLoader_checkCache_whenImageIsNotInEitherCache_shouldReturnNil() {
        let session = StubNetworkSession()
        let cacheManager = MockCacheManager()
        let urlString = makeURLString()
        let sut = APIClientImageLoader(session: session, cacheManager: cacheManager)
        
        let image = sut.checkCache(for: urlString)
        
        #expect(cacheManager.getDataCalled == true, "Should be true.")
        #expect(cacheManager.setDataCalled == false, "Should be false.")
        #expect(image == nil, "Should be nil.")
    }
    
    // MARK: - Helper methods
    private func makeURLString() -> String {
        "https://example.com/image.png"
    }
    
    private func makeTestImage() -> UIImage {
        SFSymbols.photo!
    }
    
    private func makeTestURL() -> URL {
        URL(string: makeURLString())!
    }
}
