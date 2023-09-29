//
//  BeerDB.swift
//  Database
//
//  Created by Jacob Bartlett on 23/09/2023.
//

import Domain
import Foundation
import SwiftData

public protocol BeerDB {
    func getBeers() async throws -> [Beer]
    func save(beers: [Beer]) async throws
}

public final class BeerDBImpl: BeerDB {
    
    private let container: ModelContainer
    
    public init(inMemoryDB: Bool) throws {
        container = try ModelContainer(for: BeerModel.self)
//        let configuration = ModelConfiguration(for: BeerModel.self, isStoredInMemoryOnly: inMemoryDB)
//        container = try ModelContainer(for: BeerModel.self, configurations: configuration)
    }
    
    @MainActor
    public func getBeers() async throws -> [Beer] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<BeerModel>(
            sortBy: [SortDescriptor<BeerModel>(\.id)]
        )
        let beerModels = try context.fetch(fetchDescriptor)
        return beerModels.map { $0.beer }
    }
    
    @MainActor
    public func save(beers: [Beer]) throws {
        let context = container.mainContext
        beers
            .map { BeerModel(beer: $0) }
            .forEach {
                context.insert($0)
            }
        try context.save()
    }
}
