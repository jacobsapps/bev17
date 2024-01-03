//
//  BeerRepository.swift
//  Repository
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Combine
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
    func loadBeers() async
}

public final class BeerRepositoryImpl: BeerRepository {
    
    public private(set) var beersPublisher = CurrentValueSubject<LoadingState<[Beer]>, Never>(.idle)
    
    private let api: BeerAPI
    
    public init(api: BeerAPI = BeerAPIImpl()) {
        self.api = api
    }
    
    public func loadBeers() async {
        beersPublisher.send(.loading)
        do {
            let beers = try await api.getBeers()
            beersPublisher.send(.success(beers))

        } catch {
            beersPublisher.send(.failure(error))
        }
    }
}
