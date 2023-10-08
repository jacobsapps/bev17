//
//  BeerViewModelTests.swift
//  BevTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Combine
import Domain
import Networking
import ObservationTestUtils
import RepositoryMocks
import XCTest
@testable import Bev

final class BeerViewModelTests: XCTestCase {
    
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
    
    override func setUp() {
        super.setUp()
        mockBeerRepository = MockBeerRepository()
    }
    
    override func tearDown() {
        sut = nil
        mockBeerRepository = nil
        super.tearDown()
    }
    
    // MARK: - Combine -
    
    func test_initialState_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        XCTAssertTrue(sut.beers.isEmpty)
        XCTAssertFalse(sut.showAlert)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadBeers_callsLoadOnRepository_withCombine() async {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        await sut.loadBeers()
        XCTAssertEqual(mockBeerRepository.loadBeersCallCount, 1)
    }
    
    func test_refreshBeers_tellsRepositoryToLoad_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        let exp = expectation(description: #function)
        mockBeerRepository.didLoadBeers = { exp.fulfill() }
        sut.refreshBeers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockBeerRepository.loadBeersCallCount, 1)
    }
    
    func test_listenerSentBeersSuccessfully_setsBeers_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let sampleBeers = [Beer.sample()]
        mockBeerRepository.beersPublisher.send(.success(sampleBeers))
        waitForChanges(to: \.beers, on: sut)
        XCTAssertEqual(sampleBeers, sut.beers)
    }
    
    func test_listenerSentOfflineError_setsErrorMessageAndTogglesAlert_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let testError = BeerAPIError.offline
        mockBeerRepository.beersPublisher.send(.failure(testError))
        waitForChanges(to: \BeerViewModel.showAlert, on: sut)
        XCTAssertEqual(sut.errorMessage, BeerAPIError.offline.errorDescription)
        XCTAssertTrue(sut.showAlert)
    }
    
    func test_listenerSentURLError_setsErrorMessageAndTogglesAlert_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let testError = BeerAPIError.couldNotConstructURL
        mockBeerRepository.beersPublisher.send(.failure(testError))
        waitForChanges(to: \.showAlert, on: sut)
        XCTAssertEqual(sut.errorMessage, BeerAPIError.couldNotConstructURL.errorDescription)
        XCTAssertTrue(sut.showAlert)
    }
    
    func test_listenerSentError_setsErrorMessageAndTogglesAlert_withCombine() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        let testError = TestViewModelError.testError
        mockBeerRepository.beersPublisher.send(.failure(testError))
        waitForChanges(to: \.showAlert, on: sut)
        XCTAssertEqual(sut.errorMessage, testError.localizedDescription)
        XCTAssertTrue(sut.showAlert)
    }
    
    // MARK: - AsyncSequence -
    
    func test_initialState_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .combine)
        XCTAssertTrue(sut.beers.isEmpty)
        XCTAssertFalse(sut.showAlert)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadBeers_callsLoadOnRepository_withAsyncSequence() async {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        await sut.loadBeers()
        XCTAssertEqual(mockBeerRepository.loadBeersCallCount, 1)
    }
    
    func test_refreshBeers_tellsRepositoryToLoad_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        mockBeerRepository.stubLoadBeersResponse = .success([])
        let exp = expectation(description: #function)
        mockBeerRepository.didLoadBeers = { exp.fulfill() }
        sut.refreshBeers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockBeerRepository.loadBeersCallCount, 1)
    }
    
    func test_listenerSentBeersSuccessfully_setsBeers_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let sampleBeers = [Beer.sample()]
        mockBeerRepository.beersPublisher.send(.success(sampleBeers))
        waitForChanges(to: \.beers, on: sut)
        XCTAssertEqual(sampleBeers, sut.beers)
    }
    
    func test_listenerSentOfflineError_setsErrorMessageAndTogglesAlert_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let testError = BeerAPIError.offline
        mockBeerRepository.beersPublisher.send(.failure(testError))
        waitForChanges(to: \.showAlert, on: sut)
        XCTAssertEqual(sut.errorMessage, BeerAPIError.offline.errorDescription)
        XCTAssertTrue(sut.showAlert)
    }
    
    func test_listenerSentURLError_setsErrorMessageAndTogglesAlert_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let testError = BeerAPIError.couldNotConstructURL
        mockBeerRepository.beersPublisher.send(.failure(testError))
        waitForChanges(to: \.showAlert, on: sut)
        XCTAssertEqual(sut.errorMessage, BeerAPIError.couldNotConstructURL.errorDescription)
        XCTAssertTrue(sut.showAlert)
    }
    
    func test_listenerSentError_setsErrorMessageAndTogglesAlert_withAsyncSequence() {
        sut = BeerViewModel(repository: mockBeerRepository, strategy: .asyncSequence)
        let testError = TestViewModelError.testError
        mockBeerRepository.beersPublisher.send(.failure(testError))
        waitForChanges(to: \.showAlert, on: sut)
        XCTAssertEqual(sut.errorMessage, testError.localizedDescription)
        XCTAssertTrue(sut.showAlert)
    }
}
