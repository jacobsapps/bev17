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
    
    public var stubGetAllBeersResponse: Result<[Beer], Error>?
    public var didGetAllBeers: (() -> Void)?
    public private(set) var getAllBeersCallCount = 0
    public func getAllBeers() async throws -> [Domain.Beer] {
        defer { didGetAllBeers?() }
        getAllBeersCallCount += 1
        return try stubGetAllBeersResponse.evaluate()
    }
    
    public var stubBeersResponse: Result<[Beer], Error>?
    public var didGetBeers: (() -> Void)?
    public private(set) var getBeersCallCount = 0
    public private(set) var capturedPage: Int?
    public func getBeers(page: Int) async throws -> [Beer] {
        defer { didGetBeers?() }
        getBeersCallCount += 1
        capturedPage = page
        return try stubBeersResponse.evaluate()
    }
}
