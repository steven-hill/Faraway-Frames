//
//  ContextSaving.swift
//  Faraway Frames
//
//  Created by Steven Hill on 10/06/2026.
//

import CoreData

protocol ContextSaving {
    func save() throws
}

extension NSManagedObjectContext: ContextSaving {}
