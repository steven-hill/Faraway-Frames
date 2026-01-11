//
//  FilmsDecodingTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 11/01/2026.
//

import Testing
import Foundation
@testable import Faraway_Frames

@MainActor
struct DecodingAllFilmsTests {
    
    @Test func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturns22Films() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films.count == 22)
    }
    
    @Test func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsFirstFilmWithCorrectId() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[0].id == "2baf70d1-42bb-4437-b551-e5fed5a87abe")
    }
    
    @Test func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsLastFilmWithCorrectId() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[21].id == "790e0028-a31c-4626-a694-86b7a8cada40")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsSecondFilmWithCorrectOriginalTitle() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[1].originalTitle == "火垂るの墓")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsThirdFilmWithCorrectOriginalTitleRomanised() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[2].originalTitleRomanised == "Tonari no Totoro")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsFourthFilmWithCorrectMovieBanner() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[3].movieBanner == "https://image.tmdb.org/t/p/original/h5pAEVma835u8xoE60kmLVopLct.jpg")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsFifthFilmWithCorrectReleaseDate() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[4].releaseDate == "1991")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsSixthFilmWithCorrectRunningTime() throws {
        let films = try loadAndDecodeFilmsFromJSON()
        #expect(films[5].runningTime == "93")
    }
    
    // MARK: - Helper method
    private func loadAndDecodeFilmsFromJSON() throws -> [Film] {
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

extension Tag {
  @Tag static var codingKeysTest: Self
}
