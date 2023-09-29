//
//  MockURLSession.swift
//  NetworkingMocks
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Foundation
import TestUtilities
import Networking

public final class MockURLSession: URLSessionProtocol {
    
    public init() { }
    
    public var stubDataResponse: Result<(Data, URLResponse), Error>?
    public var capturedURL: URL?
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        capturedURL = url
        return try stubDataResponse.evaluate()
    }
}
