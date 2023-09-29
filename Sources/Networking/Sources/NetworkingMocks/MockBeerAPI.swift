//
//  MockBeerAPI.swift
//  NetworkingMocks
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Domain
import Foundation
import Networking
import TestUtilities

public final class MockBeerAPI: BeerAPI {
    
    public init() { }
    
    public var stubBeersResponse: Result<[Beer], Error>?
    public var didGetBeers: (() -> Void)?
    public private(set) var getBeersCallCount = 0
    public func getBeers() async throws -> [Beer] {
        defer { didGetBeers?() }
        getBeersCallCount += 1
        return try stubBeersResponse.evaluate()
    }
}
