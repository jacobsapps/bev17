//
//  Evaluate.swift
//  TestUtilities
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Foundation
import Testing

public extension Optional {
    
    /// Evaluate stubs in mock implementations of dependencies
    ///
    /// Stubs should be of type `Result<T, Error>?`.
    /// This method evaluates the stub in 1 of 3 ways:
    ///  1. If the Result is `nil`, the stub has not been set and the test fails
    ///  2. If the Result is `.success`, returns the value
    ///  3. If the Result is `.failure`, throws the wrapped error
    ///
    func evaluate<T>(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T where Wrapped == Result<T, Error> {
        let this = try #require(self)
        return try this.get()
    }
}
