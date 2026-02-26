//
//  StubNetworkSession.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 09/02/2026.
//

import Foundation
@testable import Faraway_Frames

struct StubNetworkSession: NetworkSession {
    let configuration: URLSessionConfiguration = .default
    var data: Data?
    var response: URLResponse?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        guard let data = data, let response = response else {
            fatalError("MockSession must be configured with data/response.")
        }
        return (data, response)
    }
}
