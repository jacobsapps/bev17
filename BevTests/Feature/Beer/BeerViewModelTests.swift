//
//  BeerViewModelTests.swift
//  BevTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Combine
import Domain
import Networking
import RepositoryMocks
import Testing
import TestUtilities
@testable import Bev
import Foundation

final class BeerViewModelTests {
    
    var sut: BeerViewModel!
    var mockBeerRepository: MockBeerRepository!
    
    private enum TestViewModelError: LocalizedError {
        case testError
        
        var errorDescription: String {
            switch self {
            case .testError: return "Test error"
            }
        }
    }
    
    init() {
        mockBeerRepository = MockBeerRepository()
    }
    
    deinit {
        sut = nil
        mockBeerRepository = nil
    }
    
    // MARK: - Combine -
    
    @Test func initialState_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        #expect(sut.beers.isEmpty)
        #expect(!sut.showAlert)
        #expect(sut.errorMessage == nil)
    }
    
    @Test func loadBeers_callsLoadOnRepository_withCombine() async {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        await sut.loadBeers()
        #expect(mockBeerRepository.loadBeersCallCount == 1)
    }
    
    @Test func refreshBeers_tellsRepositoryToLoad_withCombine() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        let exp = SwiftExpectation(timeout: 1)
        mockBeerRepository.didLoadBeers = { exp.fulfill() }
        sut.refreshBeers()
        try await exp.wait()
        #expect(mockBeerRepository.loadBeersCallCount == 1)
    }
    
    @Test func listenerSentBeersSuccessfully_setsBeers_withCombine() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let sampleBeers = [Beer.sample()]
        mockBeerRepository.beersPublisher.send(.success(sampleBeers))
        try await changes(to: \.beers, on: sut)
        #expect(sampleBeers == sut.beers)
    }
    
    @Test func listenerSentOfflineError_setsErrorMessageAndTogglesAlert_withCombine() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let testError = BeerAPIError.offline
        mockBeerRepository.beersPublisher.send(.failure(testError))
        try await changes(to: \BeerViewModel.showAlert, on: sut)
        #expect(sut.errorMessage == BeerAPIError.offline.errorDescription)
        #expect(sut.showAlert)
    }
    
    @Test func listenerSentURLError_setsErrorMessageAndTogglesAlert_withCombine() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let testError = BeerAPIError.couldNotConstructURL
        mockBeerRepository.beersPublisher.send(.failure(testError))
        try await changes(to: \BeerViewModel.showAlert, on: sut)
        #expect(sut.errorMessage == BeerAPIError.couldNotConstructURL.errorDescription)
        #expect(sut.showAlert)
    }
    
    @Test func listenerSentError_setsErrorMessageAndTogglesAlert_withCombine() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let testError = TestViewModelError.testError
        mockBeerRepository.beersPublisher.send(.failure(testError))
        try await changes(to: \BeerViewModel.showAlert, on: sut)
        #expect(sut.errorMessage == testError.localizedDescription)
        #expect(sut.showAlert)
    }
    
    // MARK: - AsyncSequence -
    
    @Test func initialState_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        #expect(sut.beers.isEmpty)
        #expect(!sut.showAlert)
        #expect(sut.errorMessage == nil)
    }
    
    @Test func loadBeers_callsLoadOnRepository_withAsyncSequence() async {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        await sut.loadBeers()
        #expect(mockBeerRepository.loadBeersCallCount == 1)
    }
    
    @Test func refreshBeers_tellsRepositoryToLoad_withAsyncSequence() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        let exp = SwiftExpectation()
        mockBeerRepository.didLoadBeers = { exp.fulfill() }
        sut.refreshBeers()
        try await exp.wait()
        #expect(mockBeerRepository.loadBeersCallCount == 1)
    }
        
    @Test func listenerSentBeersSuccessfully_setsBeers_withAsyncSequence() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let sampleBeers = [Beer.sample()]
        mockBeerRepository.beersPublisher.send(.success(sampleBeers))
        try await changes(to: \.beers, on: sut)
        #expect(sampleBeers == sut.beers)
    }
    
    @Test func listenerSentOfflineError_setsErrorMessageAndTogglesAlert_withAsyncSequence() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let testError = BeerAPIError.offline
        mockBeerRepository.beersPublisher.send(.failure(testError))
        try await changes(to: \BeerViewModel.showAlert, on: sut)
        #expect(sut.errorMessage == BeerAPIError.offline.errorDescription)
        #expect(sut.showAlert)
    }
    
    @Test func listenerSentURLError_setsErrorMessageAndTogglesAlert_withAsyncSequence() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let testError = BeerAPIError.couldNotConstructURL
        mockBeerRepository.beersPublisher.send(.failure(testError))
        try await changes(to: \BeerViewModel.showAlert, on: sut)
        #expect(sut.errorMessage == BeerAPIError.couldNotConstructURL.errorDescription)
        #expect(sut.showAlert)
    }
    
    @Test func listenerSentError_setsErrorMessageAndTogglesAlert_withAsyncSequence() async throws {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let testError = TestViewModelError.testError
        mockBeerRepository.beersPublisher.send(.failure(testError))
        try await changes(to: \BeerViewModel.showAlert, on: sut)
        #expect(sut.errorMessage == testError.localizedDescription)
        #expect(sut.showAlert)
    }
}
