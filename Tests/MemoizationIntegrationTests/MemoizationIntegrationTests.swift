////
////  MemoizationIntegrationTests.swift
////  Memoization
////
////  Created by Bruno on 24/11/24.
////
//
//import Memoization
//import SwiftParser
//import SwiftSyntax
//import SwiftSyntaxBuilder
//import SwiftSyntaxMacros
//import SwiftSyntaxMacrosTestSupport
//import XCTest
//
//final class MemoizationIntegrationTests: XCTestCase {
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
//}
