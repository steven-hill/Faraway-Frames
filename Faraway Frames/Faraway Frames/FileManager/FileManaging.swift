//
//  FileManaging.swift
//  Faraway Frames
//
//  Created by Steven Hill on 28/04/2026.
//

import Foundation

protocol FileManaging {
    func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey : Any]?) -> Bool
}

extension FileManager: FileManaging {}
