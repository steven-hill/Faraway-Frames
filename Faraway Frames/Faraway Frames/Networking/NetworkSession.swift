//
//  NetworkSession.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/02/2026.
//

import Foundation

protocol NetworkSession {
    var configuration: URLSessionConfiguration { get }
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
