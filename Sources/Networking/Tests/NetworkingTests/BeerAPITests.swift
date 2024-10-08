//
//  BeerAPITests.swift
//  NetworkingTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Foundation
import Domain
import Testing
import NetworkingMocks
@testable import Networking

final class BeerAPITests {
    
    private var sut: BeerAPI!
    private var mockURLSession: MockURLSession!
    
    private enum TestError: Error {
        case testError
    }
    
    init() {
        mockURLSession = MockURLSession()
        sut = BeerAPIImpl(session: mockURLSession)
    }
    
    deinit {
        sut = nil
        mockURLSession = nil
    }
    
    @Test func getBeers_createsCorrectURL() async {
        mockURLSession.stubDataResponse = .success((Data(), URLResponse()))
        _ = try? await sut.getBeers()
        #expect(mockURLSession.capturedURL?.host == "api.punkapi.com")
        #expect(mockURLSession.capturedURL?.path == "/v2/beers")
        #expect(mockURLSession.capturedURL?.query(percentEncoded: false) == "page=1&per_page=50")    
    }
    
    @Test func getBeers_returnsBeer() async {
        let expectedBeer = [Beer.sample()]
        let beerData = try? JSONEncoder().encode(expectedBeer)
        mockURLSession.stubDataResponse = .success((beerData ?? Data(), URLResponse()))
        let resultBeer = try? await sut.getBeers()
        #expect(resultBeer == expectedBeer)
    }
    
    @Test func getBeers_returnsEmptyArray() async {
        let expectedEmptyArray = [Beer]()
        let emptyData = try? JSONEncoder().encode(expectedEmptyArray)
        mockURLSession.stubDataResponse = .success((emptyData ?? Data(), URLResponse()))
        let resultBeer = try? await sut.getBeers()
        #expect(resultBeer == expectedEmptyArray)
    }

    @Test func getBeers_invalidURL_throwsCouldNotConstructURLError() async {
        sut = BeerAPIImpl(baseURL: "<>^`{|}", session: mockURLSession)
        await #expect(throws: BeerAPIError.couldNotConstructURL,
                      performing: {
            try await sut.getBeers()
        })
    }
    
    @Test func getBeers_offline_throwsError() async {
        let testError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        mockURLSession.stubDataResponse = .failure(testError)
        await #expect(throws: BeerAPIError.offline,
                      performing: {
            try await sut.getBeers()
        })
    }
    
    @Test func getBeers_requestFailure_throwsError() async {
        let testError = TestError.testError
        mockURLSession.stubDataResponse = .failure(testError)
        await #expect(throws: TestError.testError,
                      performing: {
            try await sut.getBeers()
        })
    }
    
    @Test func getBeers_invalidJSON_throwsDecodingError() async {
        let invalidJSONData = "invalid_json".data(using: .utf8)!
        mockURLSession.stubDataResponse = .success((invalidJSONData, URLResponse()))
        await #expect(throws: DecodingError.self,
                      performing: {
            try await sut.getBeers()
        })
    }

    @Test func getBeers_emptyData_throwsDecodingError() async {
        let emptyData = Data()
        mockURLSession.stubDataResponse = .success((emptyData, URLResponse()))
        await #expect(throws: DecodingError.self,
                      performing: {
            try await sut.getBeers()
        })
    }
}
