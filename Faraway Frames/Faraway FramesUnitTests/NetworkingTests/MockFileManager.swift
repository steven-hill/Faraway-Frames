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
    let filePath = "/dev/null"
    var writeWasCalled = false
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [URL(filePath: filePath, directoryHint: .isDirectory)]
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        writeWasCalled = true
        mockFiles[path] = data
        return true
    }
}
