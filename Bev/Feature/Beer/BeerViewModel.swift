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

class Cache {
    static let shared = Cache()
    private init() {}

    private var cache: [Int: Int] = [:]
   
    func get(_ key: Int) -> Int? {
        cache[key]
    }
   
    func set(_ key: Int, value: Int) {
        cache[key] = value
    }
}

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
        
        Task {
            try await callChatGPTAPI(prompt: "Hello, World!")
            let cache = Cache.shared
            await withTaskGroup(of: Void.self) { group in
                    for i in 0..<10_000 {
                        group.addTask {
                            cache.set(Int.random(in: 0..<100), value: i)
                        }
                    }
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
    
    func callChatGPTAPI(prompt: String) async throws -> Data {
        let url = URL(string: "https://api.chatgpt.com")!
        var request = URLRequest(url: url)
        let apiKey = "12345678-90ab-cdef-1234-567890abcdef"
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        return try await URLSession.shared.data(for: request).0
    }
}
    
//func getAPIKeyObfuscated() -> String? {
//    decode(obfuscated: "AQIDBAUGBwgACQBRUgBTVFVWAAECAwQABQYHCAkAUVJTVFVW")
//}
//
//func getAPIKeyPlist() -> String? {
//    Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
//}
//    
//func getAPIKeyObfuscated() -> String? {
//    decode(obfuscated: "AQIDBAUGBwgACQBRUgBTVFVWAAECAwQABQYHCAkAUVJTVFVW")
//}

//private func obfuscate(key: String) -> String? {
//    let salt = "00000000-0000-0000-0000-000000000000"
//    guard let keyData = key.data(using: .utf8),
//          let saltData = salt.data(using: .utf8) else {
//        return nil
//    }
//    let obfuscatedData = zip(keyData, saltData).map { $0 ^ $1 }
//    let obfuscatedBase64 = Data(obfuscatedData).base64EncodedString()
//    return obfuscatedBase64
//}
//
//private func decode(obfuscated: String) -> String? {
//    let salt = "00000000-0000-0000-0000-000000000000"
//    guard let obfuscatedData = Data(base64Encoded: obfuscated),
//          let saltData = salt.data(using: .utf8) else {
//        return nil
//    }
//    let apiKeyData = zip(obfuscatedData, saltData).map { $0 ^ $1 }
//    return String(bytes: apiKeyData, encoding: .utf8)
//}
//}
