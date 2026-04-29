//
//  FileManaging.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/04/2026.
//

import Foundation

protocol FileManaging {
    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL]
    func createFile(atPath path: String,
                    contents data: Data?,
                    attributes attr: [FileAttributeKey : Any]?) -> Bool
}

extension FileManager: FileManaging {}
