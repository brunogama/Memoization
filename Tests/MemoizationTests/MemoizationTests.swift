import MacroTesting
import InlineSnapshotTesting
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MemoizationMacros

final class MemoizationTests: XCTestCase {
    
    override func invokeTest() {
        
        withMacroTesting(record: false, macros: ["memoized": MemoizeMacro.self]) {
            super.invokeTest()
        }
    }

    func testCachedMacroExpansion() throws {
        assertMacro {
         """
         class A {
             @memoized
             func fibonacci(_ n: Int) -> Int {
                 if n <= 1 {
                     return n
                 }
                 return fibonacci(n - 1) + fibonacci(n - 2)
             }
         }
         """
        } expansion: {
            """
            class A {
                func fibonacci(_ n: Int) -> Int {
                    if n <= 1 {
                        return n
                    }
                    return fibonacci(n - 1) + fibonacci(n - 2)
                }

                private var memoizedFibonacciStorage: MemoizeStorage<Int>? = .init()

                func memoizedFibonacci(_ n: Int) -> Int {
                    let key = CacheKey(n)
                    
                    if let cachedResult = memoizedFibonacciStorage?.getValue(for: key) {
                        return cachedResult
                    }
                    
                    let result = fibonacci(n)
                    memoizedFibonacciStorage?[key] = CacheResult(result)
                    return result
                }

                func resetCacheFibonacci() {
                    memoizedFibonacciStorage?.clear()
                }
            }
            """
        }
    }
    
    func test_memoized_on_two_parameter_function() {
        assertMacro {
            """
            class Spam {
                @memoized
                func add(_ a: Int, _ b: Int) -> Int {
                    return a + b
                }
            }
            """
        } expansion: {
            """
            class Spam {
                func add(_ a: Int, _ b: Int) -> Int {
                    return a + b
                }

                private var memoizedAddStorage: MemoizeStorage<Int>? = .init()

                func memoizedAdd(_ a: Int, , _ b: Int) -> Int {
                    let key = CacheKey(a, b)
                    
                    if let cachedResult = memoizedAddStorage?.getValue(for: key) {
                        return cachedResult
                    }
                    
                    let result = add(a, b)
                    memoizedAddStorage?[key] = CacheResult(result)
                    return result
                }

                func resetCacheAdd() {
                    memoizedAddStorage?.clear()
                }
            }
            """
        }
    }
}
