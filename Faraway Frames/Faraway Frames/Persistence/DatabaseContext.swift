//
//  DatabaseContext.swift
//  Faraway Frames
//
//  Created by Steven Hill on 20/06/2026.
//

import CoreData

protocol DatabaseContext: Sendable {
    func perform<T>(_ block: @escaping @Sendable () throws -> T) async rethrows -> T where T: Sendable
    nonisolated func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSManagedObject
}

extension NSManagedObjectContext: DatabaseContext {
    func perform<T>(_ block: @escaping @Sendable () throws -> T) async rethrows -> T where T: Sendable {
        return try await self.perform(schedule: .immediate, block)
    }
}
