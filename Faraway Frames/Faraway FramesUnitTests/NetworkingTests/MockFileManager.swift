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
    private(set) var createDirectoryCallCount = 0
    private(set) var readCallCount = 0
    private(set) var writeCallCount = 0
    
    func fileExists(atPath path: String) -> Bool {
        let url = URL(filePath: path)
        return mockStorage[url] != nil
    }
    
    func read(from url: URL) throws -> Data {
        readCallCount += 1
        if let data = mockStorage[url] {
            return data
        }
        throw NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileReadNoSuchFileError
        )
    }
    
    func write(
        data: Data,
        to url: URL,
        options: Data.WritingOptions
    ) throws {
        writeCallCount += 1
        mockStorage[url] = data
    }
    
    func createDirectory(
        at url: URL,
        withIntermediateDirectories: Bool,
        attributes: [FileAttributeKey : Any]?
    ) throws {
        createDirectoryCallCount += 1
    }
    
    func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL] {
        return [URL(filePath: "/mock/directory")]
    }
}
