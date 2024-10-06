//
//  ObservationTestUtils.swift
//  Domain
//
//  Created by Jacob Bartlett on 06/10/2024.
//

import Foundation
import Observation
import Testing

/// Waits for changes to a property at a given key path of an `@Observable` entity.
///
/// Uses the Observation framework's global `withObservationTracking` function to track changes to a specific property.
/// By using wildcard assignment (`_ = ...`), we 'touch' the property without wasting CPU cycles.
///
/// - Parameters:
///   - keyPath: The key path of the property to observe.
///   - parent: The observable view model that contains the property.
///   - timeout: The time (in seconds) to wait for changes before timing out. Defaults to `1.0`.
///   
public func changes<T, U>(to keyPath: KeyPath<T, U>, on parent: T, timeout: Double = 1.0) async throws {
    let exp = SwiftExpectation(timeout: timeout)
    withObservationTracking {
        _ = parent[keyPath: keyPath]
    } onChange: {
        exp.fulfill()
    }
    try await exp.wait()
}
