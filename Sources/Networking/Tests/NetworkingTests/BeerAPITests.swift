//
//  BeerAPITests.swift
//  NetworkingTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

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
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    @Test func getBeers_createsCorrectURL() async {
        mockURLSession.stubDataResponse = .success((Data(), URLResponse()))
        _ = try? await sut.getBeers()
        XCTAssertEqual(mockURLSession.capturedURL?.host, "api.punkapi.com")
        XCTAssertEqual(mockURLSession.capturedURL?.path, "/v2/beers")
        XCTAssertEqual(mockURLSession.capturedURL?.query(percentEncoded: false), "page=1&per_page=50")    
    }
    
    @Test func getBeers_returnsBeer() async {
        let expectedBeer = [Beer.sample()]
        let beerData = try? JSONEncoder().encode(expectedBeer)
        mockURLSession.stubDataResponse = .success((beerData ?? Data(), URLResponse()))
        let resultBeer = try? await sut.getBeers()
        XCTAssertEqual(resultBeer, expectedBeer)
    }
    
    @Test func getBeers_returnsEmptyArray() async {
        let expectedEmptyArray = [Beer]()
        let emptyData = try? JSONEncoder().encode(expectedEmptyArray)
        mockURLSession.stubDataResponse = .success((emptyData ?? Data(), URLResponse()))
        let resultBeer = try? await sut.getBeers()
        XCTAssertEqual(resultBeer, expectedEmptyArray)
    }

    @Test func getBeers_invalidURL_throwsCouldNotConstructURLError() async {
        sut = BeerAPIImpl(baseURL: "<>^`{|}", session: mockURLSession)
        do {
            _ = try await sut.getBeers()
            XCTFail("Expected to fail")
            
        } catch {
            XCTAssertEqual(error as? BeerAPIError, .couldNotConstructURL)
        }
    }
    
    @Test func getBeers_offline_throwsError() async {
        let testError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        mockURLSession.stubDataResponse = .failure(testError)
        do {
            _ = try await sut.getBeers()
            XCTFail("Expected to fail")
            
        } catch {
            XCTAssertEqual(error as? BeerAPIError, .offline)
        }
    }
    
    @Test func getBeers_requestFailure_throwsError() async {
        let testError = TestError.testError
        mockURLSession.stubDataResponse = .failure(testError)
        do {
            _ = try await sut.getBeers()
            XCTFail("Expected to fail")
            
        } catch {
            XCTAssertEqual(error as? TestError, testError)
        }
    }
    
    @Test func getBeers_invalidJSON_throwsDecodingError() async {
        let invalidJSONData = "invalid_json".data(using: .utf8)!
        mockURLSession.stubDataResponse = .success((invalidJSONData, URLResponse()))
        do {
            _ = try await sut.getBeers()
            XCTFail("Expected to fail")
            
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    @Test func getBeers_emptyData_throwsDecodingError() async {
        let emptyData = Data()
        mockURLSession.stubDataResponse = .success((emptyData, URLResponse()))
        do {
            _ = try await sut.getBeers()
            XCTFail("Expected to fail")
            
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
}
