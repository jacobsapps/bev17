//
//  MockBeerDB.swift
//  DatabaseMocks
//
//  Created by Jacob Bartlett on 23/09/2023.
//

import Domain
import Foundation
import Database
import TestUtilities

public final class MockBeerDB: BeerDB {
    
    public init() { }
    
    public var stubGetBeersResponse: Result<[Beer], Error>?
    public var didGetBeers: (() -> Void)?
    public private(set) var getBeersCallCount = 0
    public func getBeers() throws -> [Beer] {
        defer { didGetBeers?() }
        getBeersCallCount += 1
        return try stubGetBeersResponse.evaluate()
    }
    
    public var stubSaveBeersResponse: Result<Void, Error>?
    public var didSaveBeers: (() -> Void)?
    public private(set) var saveBeersCallCount = 0
    public func save(beers: [Beer]) throws {
        defer { didSaveBeers?() }
        saveBeersCallCount += 1
        return try stubSaveBeersResponse.evaluate()
    }
}
