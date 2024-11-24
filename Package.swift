// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Memoization",
    platforms: [.macOS(.v14), .iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v14)],
    products: [
        .library(name: "Memoization", targets: ["Memoization"]),
        .executable(name: "MemoizationClient", targets: ["MemoizationClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.5.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.4"),
    ],
    targets: [
        .target(name: "MemoizationCore", dependencies: [], path: "Sources/MemoizationCore"),
        .macro(
            name: "MemoizationMacros",
            dependencies: [
                "MemoizationCore", .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ]
        ),
        .target(name: "Memoization", dependencies: ["MemoizationMacros", "MemoizationCore"]),
        .executableTarget(name: "MemoizationClient", dependencies: ["Memoization"]),
        .testTarget(
            name: "MemoizationTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "MemoizationMacros"
            ],
            path: "Tests/MemoizationTests"
        ),
    ]
)
