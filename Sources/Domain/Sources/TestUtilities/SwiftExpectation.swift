//
//  SwiftExpectation.swift
//  Domain
//
//  Created by Jacob Bartlett on 06/10/2024.
//

import Foundation
import Testing 

public final class SwiftExpectation {
    
    private let timeout: Double
    private var isFulfilled: Bool = false
    
    public func fulfill() {
        isFulfilled = true
    }
    
    public init(timeout: Double = 1) {
        self.timeout = timeout
    }
    
    public func wait() async throws {
        try await Task.sleep(for: .seconds(timeout))
        try #require(isFulfilled)
    }
}
