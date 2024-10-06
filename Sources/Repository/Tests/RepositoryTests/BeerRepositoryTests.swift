//
//  BeerRepositoryTests.swift
//  RepositoryTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Combine
import Domain
import NetworkingMocks
import DatabaseMocks
import Testing
import TestUtilities
@testable import Repository

final class BeerRepositoryTests {

    var sut: BeerRepository!
    var mockBeerAPI: MockBeerAPI!
    var mockBeerDB: MockBeerDB!
    var cancel: AnyCancellable?
    
    private enum TestRepositoryError: Error, Equatable {
        case testError
    }
    
    init() {
        mockBeerAPI = MockBeerAPI()
        mockBeerDB = MockBeerDB()
        sut = BeerRepositoryImpl(api: mockBeerAPI, db: mockBeerDB)
    }
    
    deinit {
        cancel?.cancel()
        cancel = nil
        sut = nil
        mockBeerAPI = nil
        mockBeerDB = nil
    }
    
    // MARK: - DataAccessStrategy.fastestAvailable

    // MARK: - DataAccessStrategy.upToDateWithFallback
    
    @Test func loadBeers_upToDateWithFallback_callsAPI() async {
        mockBeerAPI.stubGetAllBeersResponse = .success([])
        mockBeerDB.stubSaveBeersResponse = .success(())
        await sut.loadBeers(strategy: .upToDateWithFallback)
        #expect(mockBeerAPI.getAllBeersCallCount == 1)
        #expect(mockBeerDB.saveBeersCallCount == 1)
    }
    
    @Test func loadBeers_success_sendsBeersToPublisher() async throws {

        let expectedBeers = [Beer.sample()]
        mockBeerAPI.stubGetAllBeersResponse = .success(expectedBeers)
        mockBeerDB.stubSaveBeersResponse = .success(())

        if case .success(let beers) = try await getLoadBeersTestResult(strategy: .upToDateWithFallback) {
            #expect(beers == expectedBeers)

        } else {
            #expect(Bool(false))
        }
    }
    
    @Test func loadBeers_failure_sendsErrorToPublisher() async throws {

        let testError = TestRepositoryError.testError
        mockBeerAPI.stubGetAllBeersResponse = .failure(testError)
        mockBeerDB.stubGetBeersResponse = .failure(testError)

        if case .failure(let error) = try await getLoadBeersTestResult(strategy: .upToDateWithFallback) {
            #expect(error as? TestRepositoryError == testError)

        } else {
            #expect(Bool(false))
        }
    }
    
    // MARK: - DataAccessStrategy.returnMultipleTimes
    
    // MARK: - Helpers -
    
    private func getLoadBeersTestResult(strategy: DataAccessStrategy) async throws -> LoadingState<[Beer]>? {
        var testResult: LoadingState<[Beer]>?
        
        let exp = SwiftExpectation()
        cancel = sut.beersPublisher
            .dropFirst(2)
            .sink(receiveValue: {
                testResult = $0
                exp.fulfill()
            })
        
        await sut.loadBeers(strategy: strategy)
        try await exp.wait()
        
        return testResult
    }
}
