//
//  CacheResult.swift
//  Memoization
//
//  Created by Bruno on 24/11/24.
//

public struct CacheResult<V: Equatable> {
    public let result: V

    public init(_ result: V) {
        self.result = result
    }
}
