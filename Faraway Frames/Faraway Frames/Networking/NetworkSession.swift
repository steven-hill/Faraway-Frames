//
//  NetworkSession.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/02/2026.
//

import Foundation

protocol NetworkSession {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
