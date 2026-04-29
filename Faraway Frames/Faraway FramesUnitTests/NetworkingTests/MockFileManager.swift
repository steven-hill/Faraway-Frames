//
//  MockFileManager.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/04/2026.
//

import Foundation
@testable import Faraway_Frames

final class MockFileManager: FileManaging {
    var mockFiles: [String: Data] = [:]
    var writeWasCalled = false
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        []
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        writeWasCalled = true
        mockFiles[path] = data
        return true
    }
}
