//
//  URLSessionProtocol.swift
//  Networking
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Foundation

public protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }
