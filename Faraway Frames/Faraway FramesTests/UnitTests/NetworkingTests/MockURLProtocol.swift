//
//  MockURLProtocol.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 13/01/2026.
//

import Foundation
import Testing

final class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            Issue.record("No request handler provided.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            Issue.record("Error handling the request: \(error).")
        }
    }
    
    override func stopLoading() {}
}
