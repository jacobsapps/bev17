//
//  ObservationTracking.swift
//  BevTests
//
//  Created by Jacob Bartlett on 01/10/2023.
//

import Foundation
import Observation
import XCTest

// MARK: - Helpers -

extension XCTestCase {
    
    /// `waitForChanges` uses the Observation framework's global `withObservationTracking` function to wait for changes to a property.
    ///
    /// The generic type `T` represents a view model and the generic type `U` represents a property on this view model.
    /// By assigning a wildcard variable `_` to the property we want to observe, we ensuring changes to the property are tracked.
    ///
    func waitForChanges<T, U>(to keyPath: KeyPath<T, U>, on parent: T, timeout: Double = 1.0) {
        let exp = expectation(description: #function)
        withObservationTracking {
            _ = parent[keyPath: keyPath]
        } onChange: {
            exp.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
}
