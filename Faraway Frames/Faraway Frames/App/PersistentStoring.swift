//
//  PersistentStoring.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/06/2026.
//

import Foundation

protocol PersistentStoring {
    func makePersistenceController() throws -> PersistenceControlling
}
