//
//  FilmMO.swift
//  Faraway Frames
//
//  Created by Steven Hill on 08/06/2026.
//

import Foundation
import CoreData

public class FilmMO: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var originalTitleRomanised: String?
    @NSManaged public var image: String?
    @NSManaged public var movieBanner: String?
    @NSManaged public var filmDescription: String?
    @NSManaged public var director: String?
    @NSManaged public var producer: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var runningTime: String?
    @NSManaged public var rottenTomatoesScore: String?
    @NSManaged public var url: String?
    @NSManaged public nonisolated var isUpNext: Bool
    @NSManaged public nonisolated var isWatched: Bool
}
