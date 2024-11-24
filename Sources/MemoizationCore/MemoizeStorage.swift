//
//  MemoizeStorage.swift
//  Memoization
//
//  Created by Bruno on 24/11/24.
//

import Foundation

open class MemoizeStorage<R: Equatable> {
    private let lock: NSLock
    private var _storage: [CacheKey: CacheResult<R>]
    private var storage: [CacheKey: CacheResult<R>] {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _storage
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _storage = newValue
        }
    }

    public init() {
        _storage = [:]
        lock = NSLock()
    }

    open subscript(key: CacheKey) -> CacheResult<R>? {
        get {
            storage[key]
        }
        set {
            storage[key] = newValue
        }
    }

    open func getValue(for key: CacheKey) -> R? {
        storage[key]?.result
    }

    open func clear() {
        storage = [:]
    }
}
