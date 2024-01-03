//
//  BeerRepositoryTests.swift
//  RepositoryTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Combine
import Domain
import NetworkingMocks
import XCTest
@testable import Repository

final class BeerRepositoryTests: XCTestCase {
    
    var mockBeerAPI: MockBeerAPI!
    var sut: BeerRepository!
    var cancel: AnyCancellable?
    
    private enum TestRepositoryError: Error, Equatable {
        case testError
    }
    
    override func setUp() {
        super.setUp()
        mockBeerAPI = MockBeerAPI()
        sut = BeerRepositoryImpl(api: mockBeerAPI)
    }
    
    override func tearDown() {
        cancel?.cancel()
        cancel = nil
        sut = nil
        mockBeerAPI = nil
        super.tearDown()
    }
    
    func test_loadBeers_callsAPI() async {
        mockBeerAPI.stubBeersResponse = .success([])
        await sut.loadBeers()
        XCTAssertEqual(mockBeerAPI.getBeersCallCount, 1)
    }
    
    func test_loadBeers_success_sendsBeersToPublisher() async {

        let expectedBeers = [Beer.sample()]
        mockBeerAPI.stubBeersResponse = .success(expectedBeers)

        if case .success(let beers) = await getLoadBeersTestResult() {
            XCTAssertEqual(beers, expectedBeers)

        } else {
            XCTFail(#function)
        }
    }
    
    func test_loadBeers_failure_sendsErrorToPublisher() async {

        let testError = TestRepositoryError.testError
        mockBeerAPI.stubBeersResponse = .failure(testError)

        if case .failure(let error) = await getLoadBeersTestResult() {
            XCTAssertEqual(error as? TestRepositoryError, testError)

        } else {
            XCTFail(#function)
        }
    }
    
    private func getLoadBeersTestResult() async -> LoadingState<[Beer]>? {
        var testResult: LoadingState<[Beer]>?
        
        let exp = expectation(description: #function)
        cancel = sut.beersPublisher
            .dropFirst(2)
            .sink(receiveValue: {
                testResult = $0
                exp.fulfill()
            })
        
        await sut.loadBeers()
        await fulfillment(of: [exp], timeout: 1)

        return testResult
    }
}
