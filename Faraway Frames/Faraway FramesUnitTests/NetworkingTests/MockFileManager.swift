//
//  MockFileManager.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/04/2026.
//

import Foundation
@testable import Faraway_Frames

final class MockFileManager: FileManaging {
    var mockStorage: [URL: Data] = [:]
    var didCreateDirectory = false
    var readWasCalled = false
    var writeWasCalled = false
    
    func fileExists(atPath path: String) -> Bool {
        let url = URL(filePath: path)
        return mockStorage[url] != nil
    }
    
    func read(from url: URL) throws -> Data {
        readWasCalled = true
        if let data = mockStorage[url] {
            return data
        }
        throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError)
    }
    
    func write(data: Data, to url: URL, options: Data.WritingOptions) throws {
        writeWasCalled = true
        mockStorage[url] = data
    }
    
    func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]?) throws {
        didCreateDirectory = true
    }
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [URL(filePath: "/mock/directory")]
    }
}
