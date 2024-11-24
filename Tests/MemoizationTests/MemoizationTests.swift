import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftParser
import XCTest

#if canImport(MemoizationMacros)
import MemoizationMacros

let testMacros: [String: Macro.Type] = [
    "memoized": MemoizeMacro.self
]
#endif

final class MemoizationTests: XCTestCase {
    
    func testCachedMacroExpansion() throws {
        #if canImport(MemoizationMacros)
        assertMacroExpansion(
            #"""
            class A {
                @memoized
                func fibonacci(_ n: Int) -> Int {
                    if n <= 1 {
                        return n
                    }
                    return fibonacci(n - 1) + fibonacci(n - 2)
                }
            }
            """#,
            expandedSource: #"""
            class A {
                func fibonacci(_ n: Int) -> Int {
                    if n <= 1 {
                        return n
                    }
                    return fibonacci(n - 1) + fibonacci(n - 2)
                }

                private var memoizedFibonacciStorage = MemoizeStorage<Int>()

                func memoizedFibonacci(_ n: Int) -> Int {
                    let key = CacheKey(n)
                    if let cachedResult = memoizedFibonacciStorage.getValue(for: key) {
                        return cachedResult
                    }
                    let result = fibonacci(n)
                    memoizedFibonacciStorage[key] = CacheResult(result)
                    return result
                }

                func resetMemoizedFibonacci() {
                    memoizedFibonacciStorage.clear()
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
