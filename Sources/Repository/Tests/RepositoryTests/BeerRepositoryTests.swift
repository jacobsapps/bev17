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
import XCTest
@testable import Repository

final class BeerRepositoryTests: XCTestCase {

    var sut: BeerRepository!
    var mockBeerAPI: MockBeerAPI!
    var mockBeerDB: MockBeerDB!
    var cancel: AnyCancellable?
    
    private enum TestRepositoryError: Error, Equatable {
        case testError
    }
    
    override func setUp() {
        super.setUp()
        mockBeerAPI = MockBeerAPI()
        mockBeerDB = MockBeerDB()
        sut = BeerRepositoryImpl(api: mockBeerAPI, db: mockBeerDB)
    }
    
    override func tearDown() {
        cancel?.cancel()
        cancel = nil
        sut = nil
        mockBeerAPI = nil
        mockBeerDB = nil
        super.tearDown()
    }
    
    // MARK: - DataAccessStrategy.fastestAvailable

    // MARK: - DataAccessStrategy.upToDateWithFallback
    
    func test_loadBeers_upToDateWithFallback_callsAPI() async {
        mockBeerAPI.stubGetAllBeersResponse = .success([])
        mockBeerDB.stubSaveBeersResponse = .success(())
        await sut.loadBeers(strategy: .upToDateWithFallback)
        XCTAssertEqual(mockBeerAPI.getAllBeersCallCount, 1)
        XCTAssertEqual(mockBeerDB.saveBeersCallCount, 1)
    }
    
    func test_loadBeers_success_sendsBeersToPublisher() async {

        let expectedBeers = [Beer.sample()]
        mockBeerAPI.stubGetAllBeersResponse = .success(expectedBeers)
        mockBeerDB.stubSaveBeersResponse = .success(())

        if case .success(let beers) = await getLoadBeersTestResult(strategy: .upToDateWithFallback) {
            XCTAssertEqual(beers, expectedBeers)

        } else {
            XCTFail(#function)
        }
    }
    
    func test_loadBeers_failure_sendsErrorToPublisher() async {

        let testError = TestRepositoryError.testError
        mockBeerAPI.stubGetAllBeersResponse = .failure(testError)
        mockBeerDB.stubGetBeersResponse = .failure(testError)

        if case .failure(let error) = await getLoadBeersTestResult(strategy: .upToDateWithFallback) {
            XCTAssertEqual(error as? TestRepositoryError, testError)

        } else {
            XCTFail(#function)
        }
    }
    
    // MARK: - DataAccessStrategy.returnMultipleTimes
    
    // MARK: - Helpers -
    
    private func getLoadBeersTestResult(strategy: DataAccessStrategy) async -> LoadingState<[Beer]>? {
        var testResult: LoadingState<[Beer]>?
        
        let exp = expectation(description: #function)
        cancel = sut.beersPublisher
            .dropFirst(2)
            .sink(receiveValue: {
                testResult = $0
                exp.fulfill()
            })
        
        await sut.loadBeers(strategy: strategy)
        await fulfillment(of: [exp], timeout: 1)
        
        return testResult
    }
}
