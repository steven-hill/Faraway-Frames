//
//  FilmsListAPIClientTests.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 13/01/2026.
//

import Testing
import Foundation
@testable import Faraway_Frames

@Suite(.serialized)
struct FilmsListAPIClientTests {
    
    @Test func fetchAllFilms_decodesDataOn200ResponseWithCorrectURL() async throws {
        let urlString = makeFilmsURLString()
        let filmsListAPIClient = await makeFilmsListAPIClient()
        let mockFilmsData = makeValidMockFilmsData()
        
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == urlString)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockFilmsData)
        }
        let result = try await filmsListAPIClient.fetchAllFilms()
        
        #expect(!result.isEmpty, "The films array should not be empty.")
        #expect(result.count == 1, "Should be one film in the array.")
    }
    
    @Test func fetchAllFilms_throwsOnNon200Response() async throws {
        let urlString = makeFilmsURLString()
        let filmsListAPIClient = await makeFilmsListAPIClient()
        let mockFilmsData = Data()
        
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == urlString)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, mockFilmsData)
        }
        
        await #expect(throws: APIError.invalidStatusCode, "The error code should be .invalidStatusCode.") {
            try await filmsListAPIClient.fetchAllFilms()
        }
    }
    
    @Test func fetchAllFilms_throwsOnDataDecodingError() async throws {
        let urlString = makeFilmsURLString()
        let filmsListAPIClient = await makeFilmsListAPIClient()
        let mockInvalidData = "invalid data".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == urlString)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, mockInvalidData)
        }
        
        await #expect(throws: APIError.decodingError, "The error code should be .decodingError.") {
            try await filmsListAPIClient.fetchAllFilms()
        }
    }
    
    // MARK: - Helper methods
    private func createMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    
    private func makeFilmsURLString() -> String {
        "https://ghibliapi.vercel.app/films"
    }
    
    private func makeFilmsListAPIClient() async -> FilmsListAPIClient {
        let mockSession = createMockSession()
        return await FilmsListAPIClient(session: mockSession)
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
