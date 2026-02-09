//
//  JSONHelper.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/02/2026.
//


import Foundation
import Testing
@testable import Faraway_Frames

struct JSONHelper {
   static func loadAndDecodeFilmsFromJSON() throws -> [Film] {
       guard let bundle = Bundle(identifier: "com.StevenHill.Faraway-FramesTests"),
             let url = bundle.url(forResource: "ghibliFilms", withExtension: "json") else {
           Issue.record("ghibliFilms JSON file not found")
           return []
       }
       do {
           let data = try Data(contentsOf: url)
           return try JSONDecoder().decode([Film].self, from: data)
       } catch {
           Issue.record("ghibliFilms JSON file decoding failed with error: \(error)")
           return []
       }
   }
}