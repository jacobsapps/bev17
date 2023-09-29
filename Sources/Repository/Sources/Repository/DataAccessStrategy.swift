//
//  DataAccessStrategy.swift
//
//
//  Created by Jacob Bartlett on 24/09/2023.
//

import Foundation

/// Enumerates return strategies for a Data Access Layer, letting API
/// consumers choose the optimal approach.
///
/// Strategies include:
/// - Fastest available
/// - Up-to-date with fallback
/// - Return data from all sources
///
public enum DataAccessStrategy {
    
    /// Returns the first available data source.
    /// e.g. tries cached data, then local storage, and finally the network.
    /// Prioritizes speed over the most recent information.
    ///
    case fastestAvailable
    
    /// Prioritizes fetching the most recent data from the network.
    /// Falls back to local or cached data on errors.
    /// Prioritizes most recent data over speed.
    ///
    case upToDateWithFallback
    
    /// Returns immediately available data but updates as newer
    /// sources become accessible, like local DB or network.
    /// Aims for accuracy and speed; if the UI can tolerate refreshing.
    ///
    case returnMultipleTimes
}
