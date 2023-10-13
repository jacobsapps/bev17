//
//  BeerAPI.swift
//  Networking
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Domain
import Foundation

public protocol BeerAPI {
    func getAllBeers() async throws -> [Beer]
    func getBeers(page: Int) async throws -> [Beer]
}

public enum BeerAPIError: LocalizedError {
    
    case couldNotConstructURL
    case offline
    
    public var errorDescription: String? {
        switch self {
        case .couldNotConstructURL:
            return "Could not construct URL correctly"

        case .offline:
            return "You appear to be offline"
        }
    }
}

public final class BeerAPIImpl: BeerAPI {
    
    private enum Constants {
        static let baseURL = "https://api.punkapi.com/v2/"
        static let beersPath = "beers"
    }
    
    private let baseURL: String
    private let session: URLSessionProtocol
    
    private lazy var decoder = {
        JSONDecoder()
    }()
    
    public init(baseURL: String? = nil,
                session: URLSessionProtocol = URLSession.shared) {
        self.baseURL = baseURL ?? Constants.baseURL
        self.session = session
    }
    
    public func getAllBeers() async throws -> [Beer] {
        var currentPage: Int = 1
        var lastPageIsEmpty: Bool?
        var allBeers = [Beer]()
        while lastPageIsEmpty != .some(true) {
            let beers = try await getBeers(page: currentPage)
            allBeers.append(contentsOf: beers)
            currentPage += 1
            lastPageIsEmpty = beers.isEmpty
            print(beers)
            print(currentPage)
            print(allBeers.count)
        }
        return allBeers
    }
    
    public func getBeers(page: Int) async throws -> [Beer] {
        
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "50")
        ]
        
        guard let url = URL(string: baseURL, encodingInvalidCharacters: false)?
            .appendingPathComponent(Constants.beersPath)
            .appending(queryItems: queryItems) else {
            throw BeerAPIError.couldNotConstructURL
        }
        
        do {
            let data = try await session.data(from: url).0
            return try decoder.decode([Beer].self, from: data)
            
        } catch let error as NSError
                    where error.domain == NSURLErrorDomain
                    && error.code == NSURLErrorNotConnectedToInternet {
            throw BeerAPIError.offline
            
        } catch {
            throw error
        }
    }
}
