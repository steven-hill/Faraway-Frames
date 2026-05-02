//
//  FileManaging.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/04/2026.
//

import Foundation

protocol FileManaging {
    func createDirectory(at url: URL,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey : Any]?) throws
    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func fileExists(atPath path: String) -> Bool
    func write(data: Data, to url: URL, options: Data.WritingOptions) throws
    func read(from url: URL) throws -> Data
}

extension FileManager: FileManaging {
    func write(data: Data, to url: URL, options: Data.WritingOptions) throws {
        try data.write(to: url, options: options)
    }
    func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
}
