//
//  BeerAPI.swift
//  Networking
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Domain
import Foundation

public protocol BeerAPI {
    func getBeers() async throws -> [Beer]
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
    
    public func getBeers() async throws -> [Beer] {
        
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "500")
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
