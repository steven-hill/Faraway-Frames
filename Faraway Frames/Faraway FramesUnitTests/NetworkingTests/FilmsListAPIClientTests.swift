//
//  FilmsListAPIClientTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 13/01/2026.
//

import Testing
import Foundation
@testable import Faraway_Frames

@MainActor
struct FilmsListAPIClientTests {
    
    @Test(.tags(.networkRequest, .decoding))
    func filmsListAPIClient_fetchAllFilms_ifURLCacheDataExists_usesURLCacheData() async throws {
        let testURL = URL(string: makeFilmsURLString())
        let mockResponse = HTTPURLResponse(
            url: testURL!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
        let testCache = URLCache(memoryCapacity: 10 * 1024, diskCapacity: 10 * 1024, diskPath: "test_FilmsList_URLCache")
        let cachedResponse = CachedURLResponse(response: mockResponse, data: makeTestURLCacheFilmsData())
        testCache.removeAllCachedResponses()
        testCache.storeCachedResponse(cachedResponse, for: URLRequest(url: testURL!))
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = testCache
        let session = StubNetworkSession(configuration: configuration)
        let sut = FilmsListAPIClient(session: session)

        let films = try await sut.fetchAllFilms()
        
        #expect(films.count == 2, "Should be two films as in the cached mock data.")
    }
    
    @Test func filmsListAPIClient_saveFilmsDataToFileManager_savesAllFilmsDataToFileManager() {
        let mockData = makeValidMockFilmsData()
        let mockResponse = HTTPURLResponse(
            url: URL(string: makeFilmsURLString())!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let mockFM = MockFileManager()
        let session = StubNetworkSession(data: mockData, response: mockResponse)
        let sut = FilmsListAPIClient(session: session, fileManager: mockFM)
        
        sut.saveFilmsDataToFileManager(data: mockData)
        let expectedURL = mockFM.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appending(path: "GhibliFilms")
            .appending(path: "AllGhibliFilms.json")
        
        #expect(mockFM.didCreateDirectory, "File Manager should have created the directory.")
        #expect(mockFM.writeWasCalled, "Should be true.")
        #expect(mockFM.mockStorage[expectedURL] == mockData, "Data in File Manager should match the data that was saved.")
    }
    
    @Test func filmsListAPIClient_loadFilmsDataFromFileManager_loadsAllFilmsDataFromFileManager() {
        let mockData = makeValidMockFilmsData()
        let mockResponse = HTTPURLResponse(
            url: URL(string: makeFilmsURLString())!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let mockFM = MockFileManager()
        let session = StubNetworkSession(data: mockData, response: mockResponse)
        let sut = FilmsListAPIClient(session: session, fileManager: mockFM)
        sut.saveFilmsDataToFileManager(data: mockData)
        
        let retrievedData = sut.loadFilmsDataFromFileManager()
        
        #expect(mockFM.readWasCalled, "Should have asked File Manager to read the data.")
        #expect(mockData == retrievedData, "Data retrieved from File Manager should match the data that was saved.")
    }
    
    @Test func filmsListAPIClient_loadFilmsDataFromFileManager_returnsNilIfNoFileExists() {
        let mockData = makeValidMockFilmsData()
        let mockResponse = HTTPURLResponse(
            url: URL(string: makeFilmsURLString())!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let mockFM = MockFileManager()
        let session = StubNetworkSession(data: mockData, response: mockResponse)
        let sut = FilmsListAPIClient(session: session, fileManager: mockFM)
        
        let retrievedData = sut.loadFilmsDataFromFileManager()
        
        #expect(mockFM.readWasCalled == false, "Should have not have been called.")
        #expect(retrievedData == nil, "Should be nil.")
    }
    
    @Test(.tags(.networkRequest, .decoding))
    func filmsListAPIClient_fetchAllFilms_decodesDataOn200Response_withCorrectURL() async throws {
        let mockData = makeValidMockFilmsData()
        let mockResponse = HTTPURLResponse(
            url: URL(string: makeFilmsURLString())!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let sut = makeSUT(data: mockData, response: mockResponse)
        
        let result = try await sut.fetchAllFilms()
        
        #expect(!result.isEmpty, "The films array should not be empty.")
        #expect(result.count == 1, "Should be one film in the array.")
        #expect(result.first?.title == "Castle in the Sky", "Should be `Castle in the Sky`.")
    }
    
    @Test(.tags(.networkRequest))
    func filmsListAPIClient_fetchAllFilms_throwsOnInvalidResponse() async {
        let mockData = Data()
        let invalidResponse = URLResponse(
            url: URL(string: makeFilmsURLString())!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let sut = makeSUT(data: mockData, response: invalidResponse)
        
        await #expect(throws: APIError.invalidResponse, "The error should be .invalidResponse.") {
            try await sut.fetchAllFilms()
        }
    }
    
    @Test(.tags(.networkRequest))
    func filmsListAPIClient_fetchAllFilms_throwsOnNon200To299Response() async {
        let mockFilmsData = Data()
        let statusCode = 500
        let mockResponse = HTTPURLResponse(
            url: URL(string: makeFilmsURLString())!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        let sut = makeSUT(data: mockFilmsData, response: mockResponse)
        
        await #expect(throws: APIError.serverError(statusCode: statusCode), "The error should be .serverError(statusCode: \(statusCode).") {
            try await sut.fetchAllFilms()
        }
    }
    
    @Test(.tags(.networkRequest, .decoding))
    func filmsListAPIClient_fetchAllFilms_throwsOnDataDecodingError() async {
        let mockInvalidData = "invalid data".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(
            url: URL(string: makeFilmsURLString())!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let sut = makeSUT(data: mockInvalidData, response: mockResponse)
        
        await #expect(throws: APIError.decodingError, "The error should be .decodingError.") {
            try await sut.fetchAllFilms()
        }
    }
    
    // MARK: - Helper methods
    private func makeFilmsURLString() -> String {
        "https://ghibliapi.vercel.app/films"
    }
    
    private func makeSUT(data: Data, response: URLResponse) -> FilmsListAPIClient {
        let session = StubNetworkSession(data: data, response: response)
        return FilmsListAPIClient(session: session)
    }
    
    private func makeTestURLCacheFilmsData() -> Data {
        let json = """
            [
                {
                  "id": "2baf70d1-42bb-4437-b551-e5fed5a87abe",
                  "title": "Castle in the Sky",
                  "original_title": "天空の城ラピュタ",
                  "original_title_romanised": "Tenkū no shiro Rapyuta",
                  "image": "https://image.tmdb.org/t/p/w600_and_h900_bestv2/npOnzAbLh6VOIu3naU5QaEcTepo.jpg",
                  "movie_banner": "https://image.tmdb.org/t/p/w533_and_h300_bestv2/3cyjYtLWCBE1uvWINHFsFnE8LUK.jpg",
                  "description": "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa...",
                  "director": "Hayao Miyazaki",
                  "producer": "Isao Takahata",
                  "release_date": "1986",
                  "running_time": "124",
                  "rt_score": "95",
                  "people": [
                    "https://ghibliapi.vercel.app/people/598f7048-74ff-41e0-92ef-87dc1ad980a9"
                  ],
                  "species": [
                    "https://ghibliapi.vercel.app/species/af3910a6-429f-4c74-9ad5-dfe1c4aa04f2"
                  ],
                  "locations": [
                    "https://ghibliapi.vercel.app/locations/"
                  ],
                  "vehicles": [
                    "https://ghibliapi.vercel.app/vehicles/4e09b023-f650-4747-9ab9-eacf14540cfb"
                  ],
                  "url": "https://ghibliapi.vercel.app/films/2baf70d1-42bb-4437-b551-e5fed5a87abe"
                },
              {
                "id": "12cfb892-aac0-4c5b-94af-521852e46d6a",
                "title": "Grave of the Fireflies",
                "original_title": "火垂るの墓",
                "original_title_romanised": "Hotaru no haka",
                "image": "https://image.tmdb.org/t/p/w600_and_h900_bestv2/qG3RYlIVpTYclR9TYIsy8p7m7AT.jpg",
                "movie_banner": "https://image.tmdb.org/t/p/original/vkZSd0Lp8iCVBGpFH9L7LzLusjS.jpg",
                "description": "In the latter part of World War II, a boy and his sister, orphaned when their mother is killed in the firebombing of Tokyo, are left to survive on their own in what remains of civilian life in Japan. The plot follows this boy and his sister as they do their best to survive in the Japanese countryside, battling hunger, prejudice, and pride in their own quiet, personal battle.",
                "director": "Isao Takahata",
                "producer": "Toru Hara",
                "release_date": "1988",
                "running_time": "89",
                "rt_score": "97",
                "people": [
                  "https://ghibliapi.vercel.app/people/"
                ],
                "species": [
                  "https://ghibliapi.vercel.app/species/af3910a6-429f-4c74-9ad5-dfe1c4aa04f2"
                ],
                "locations": [
                  "https://ghibliapi.vercel.app/locations/"
                ],
                "vehicles": [
                  "https://ghibliapi.vercel.app/vehicles/"
                ],
                "url": "https://ghibliapi.vercel.app/films/12cfb892-aac0-4c5b-94af-521852e46d6a"
              }
            ]
            """
        return Data(json.utf8)
    }
    
    private func makeValidMockFilmsData() -> Data {
        let json = """
            [
                {
                  "id": "2baf70d1-42bb-4437-b551-e5fed5a87abe",
                  "title": "Castle in the Sky",
                  "original_title": "天空の城ラピュタ",
                  "original_title_romanised": "Tenkū no shiro Rapyuta",
                  "image": "https://image.tmdb.org/t/p/w600_and_h900_bestv2/npOnzAbLh6VOIu3naU5QaEcTepo.jpg",
                  "movie_banner": "https://image.tmdb.org/t/p/w533_and_h300_bestv2/3cyjYtLWCBE1uvWINHFsFnE8LUK.jpg",
                  "description": "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa...",
                  "director": "Hayao Miyazaki",
                  "producer": "Isao Takahata",
                  "release_date": "1986",
                  "running_time": "124",
                  "rt_score": "95",
                  "people": [
                    "https://ghibliapi.vercel.app/people/598f7048-74ff-41e0-92ef-87dc1ad980a9"
                  ],
                  "species": [
                    "https://ghibliapi.vercel.app/species/af3910a6-429f-4c74-9ad5-dfe1c4aa04f2"
                  ],
                  "locations": [
                    "https://ghibliapi.vercel.app/locations/"
                  ],
                  "vehicles": [
                    "https://ghibliapi.vercel.app/vehicles/4e09b023-f650-4747-9ab9-eacf14540cfb"
                  ],
                  "url": "https://ghibliapi.vercel.app/films/2baf70d1-42bb-4437-b551-e5fed5a87abe"
                }
            ]
            """
        return Data(json.utf8)
    }
}
