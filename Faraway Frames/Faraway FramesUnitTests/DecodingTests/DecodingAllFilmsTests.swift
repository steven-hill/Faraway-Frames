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
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films.count == 22, "The count should be 22.")
    }
    
    @Test func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsFirstFilmWithCorrectId() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[0].id == "2baf70d1-42bb-4437-b551-e5fed5a87abe", "Should return the id of the first film.")
    }
    
    @Test func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsLastFilmWithCorrectId() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[21].id == "790e0028-a31c-4626-a694-86b7a8cada40", "Should return the id of the last film.")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsSecondFilmWithCorrectOriginalTitle() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[1].originalTitle == "火垂るの墓", "Should return the original title of the second film.")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsThirdFilmWithCorrectOriginalTitleRomanised() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[2].originalTitleRomanised == "Tonari no Totoro", "Should return the original title romanised of the third film.")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsFourthFilmWithCorrectMovieBanner() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[3].movieBanner == "https://image.tmdb.org/t/p/original/h5pAEVma835u8xoE60kmLVopLct.jpg", "Should return the movie banner of the fourth film.")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsFifthFilmWithCorrectReleaseDate() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[4].releaseDate == "1991", "Should return the release date of the fifth film.")
    }
    
    @Test(.tags(.codingKeysTest)) func decodingJSON_fromBundleFile_toFilmsArray_successfullyReturnsSixthFilmWithCorrectRunningTime() throws {
        let films = try JSONHelper.loadAndDecodeFilmsFromJSON()
        #expect(films[5].runningTime == "93", "Should return the running time of the sixth film.")
    }
}

extension Tag {
  @Tag static var codingKeysTest: Self
}
