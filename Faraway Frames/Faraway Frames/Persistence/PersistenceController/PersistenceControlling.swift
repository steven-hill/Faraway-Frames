//
//  PersistenceControlling.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/06/2026.
//

import CoreData

protocol PersistenceControlling {
    var container: NSPersistentContainer { get }
    var viewContext: NSManagedObjectContext { get }
}
