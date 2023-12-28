//
//  BeerRepository.swift
//  Repository
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Combine
import Database
import Domain
import Foundation
import Networking

public enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}

public protocol BeerRepository {
    var beersPublisher: CurrentValueSubject<LoadingState<[Beer]>, Never> { get }
    func loadBeers(strategy: DataAccessStrategy) async
}

public final class BeerRepositoryImpl: BeerRepository {
    
    public private(set) var beersPublisher = CurrentValueSubject<LoadingState<[Beer]>, Never>(.idle)
    
    private let api: BeerAPI
    private let db: BeerDB?
    
    public init(
        api: BeerAPI = BeerAPIImpl(),
        db: BeerDB? = try? BeerDBImpl(inMemoryDB: false)
    ) {
        self.api = api
        self.db = db
    }
    
    public func loadBeers(strategy: DataAccessStrategy) async {
        beersPublisher.send(.loading)
        
        guard !isUITesting() else {
            sendMockBeers()
            return
        }
        
        do {
            switch strategy {        
            case .fastestAvailable:
                try await fastestAvailable()
                
            case .upToDateWithFallback:
                try await upToDateWithFallback()
                
            case .returnMultipleTimes:
                try await returnMultipleTimes()
            }
            
        } catch {
            beersPublisher.send(.failure(error))
        }
    }
    
    private func fastestAvailable() async throws { 
        if case .success(let beers) = beersPublisher.value {
            beersPublisher.send(.success(beers))
            return
            
        } else if let beers = try? await db?.getBeers() {
            beersPublisher.send(.success(beers))
            return
            
        } else {   
            let beers = try await api.getAllBeers()
            try? await db?.save(beers: beers)
            beersPublisher.send(.success(beers))
        }
    }
    
    private func upToDateWithFallback() async throws {
        do {
            let beers = try await api.getAllBeers()
            try? await db?.save(beers: beers)
            beersPublisher.send(.success(beers))
            
        } catch {
            if let beers = try? await db?.getBeers() {
                beersPublisher.send(.success(beers))
            } else {
                throw error
            }
        }
    }
    
    private func returnMultipleTimes() async throws {
        var didSucceed = false
        
        if case .success(let beers) = beersPublisher.value {
            beersPublisher.send(.success(beers))
            didSucceed = true
        }
        
        if let beers = try? await db?.getBeers() {
            beersPublisher.send(.success(beers))
            didSucceed = true
        }
        
        do {
            let beers = try await api.getAllBeers()
            try? await db?.save(beers: beers)
            beersPublisher.send(.success(beers))
            
        } catch {
            if !didSucceed {
                throw error
            }
        }
    }
    
    // MARK: - UI Testing Helpers
    
    private func isUITesting() -> Bool {
        ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    }
    
    private func sendMockBeers() {
        let beers = [createBeer(id: 1, name: "Buzz"), createBeer(id: 2, name: "Trashy Blonde")]
        beersPublisher.send(.success(beers))
    }
    
    private func createBeer(id: Int, name: String, imageURL: String? = "", yeast: String? = "") -> Beer {
        Beer(id: id,
             name: name,
             tagline: "",
             firstBrewed: "",
             details: "",
             imageURL: imageURL,
             abv: 0,
             ingredients: Ingredients(malt: [], hops: [], yeast: yeast),
             foodPairing: ["Peanuts"])
    }
}
