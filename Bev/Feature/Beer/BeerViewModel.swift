//
//  BeerViewModel.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Combine
import Domain
import Repository
import SwiftUI

@Observable
final class BeerViewModel {
    
    enum BeerListeningStrategy {
        case combine
        case asyncSequence
    }
    
    private(set) var beers: [Beer] = []
    private(set) var isLoading: Bool = false
    var showAlert: Bool = false
    
    private(set) var errorMessage: String?
    private var cancelBag = Set<AnyCancellable>()
    
    private let repository: BeerRepository
    
    init(repository: BeerRepository = BeerRepositoryImpl(), strategy: BeerListeningStrategy = .combine) {
        self.repository = repository
        
        switch strategy {
        case .combine:
            setupBeerListener()

        case .asyncSequence:
            Task {
                await setupBeerSequence()
            }
        }
    }
    
    func loadBeers() async {
        await repository.loadBeers(strategy: .returnMultipleTimes)
    }
    
    func refreshBeers() {
        Task {
            await repository.loadBeers(strategy: .upToDateWithFallback)
        }
    }
    
    private func setupBeerListener() {
        repository.beersPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { loadingState in
                Task { [weak self] in
                    await self?.handleBeer(loadingState: loadingState)
                }
            }).store(in: &cancelBag)
    }
    
    private func setupBeerSequence() async {
        for await loadingState in repository.beersPublisher.values {
            await handleBeer(loadingState: loadingState)
        }
    }
    
    @MainActor
    private func handleBeer(loadingState: LoadingState<[Beer]>) {
        switch loadingState {
        case .idle:
            isLoading = false
            return
            
        case .loading:
            isLoading = true
            
        case .success(let beers):
            isLoading = false
            self.beers = beers
            
        case .failure(let error):
            isLoading = false
            showAlert.toggle()
            errorMessage = error.localizedDescription
        }
    }
}
