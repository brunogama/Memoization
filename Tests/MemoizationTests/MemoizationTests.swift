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
        
        withMacroTesting(macros: ["memoized": MemoizeMacro.self]) {
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

                private var memoizedFibonacciStorage = MemoizeStorage<Int>()

                public func memoizedFibonacci(_ n: Int) -> Int {
                    let key = CacheKey(n)
                    if let cachedResult = memoizedFibonacciStorage.getValue(for: key) {
                        return cachedResult
                    }
                    let result = fibonacci(n)
                    memoizedFibonacciStorage[key] = CacheResult(result)
                    return result
                }

                public func resetMemoizedFibonacci() {
                    memoizedFibonacciStorage.clear()
                }
            }
            """
        }
    }
    
    // MARK: - Integration
    
//    func testCachedMacroExpansion() throws {
//        class A {
//            @memoized
//            func fibonacci(_ n: Int) -> Int {
//                if n <= 1 {
//                    return n
//                }
//                return fibonacci(n - 1) + fibonacci(n - 2)
//            }
//        }
//
//        let a = A()
//        let result = a.fibonacci(10)
//        XCTAssertEqual(result, 55)
//        let result2 = a.memoizedFibonacci(10)
//        XCTAssertEqual(result2, 55)
//    }
}
