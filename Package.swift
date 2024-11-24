// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Memoization",
    platforms: [.macOS(.v14), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Memoization",
            targets: ["Memoization"]
        ),
        .executable(
            name: "MemoizationClient",
            targets: ["MemoizationClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest")
    ],
    targets: [
        .target(
            name: "MemoizationCore",
            dependencies: [],
            path: "Sources/MemoizationCore"
        ),
        .macro(
            name: "MemoizationMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(name: "Memoization", dependencies: ["MemoizationMacros", "MemoizationCore"]),

        .executableTarget(name: "MemoizationClient", dependencies: ["Memoization"]),

        .testTarget(
            name: "MemoizationTests",
            dependencies: [
                "MemoizationMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
