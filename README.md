# Memoization

**Memoization** is a Swift compiler plugin that provides a `@memoized` macro for automatically memoizing function results. By leveraging Swift's powerful macro system, `@memoized` simplifies caching function outputs, improving performance by avoiding redundant computations for repeated inputs.

## Features

*   Automatic Caching: Automatically caches function results based on input parameters.
*   Thread-Safe Storage: Utilizes a thread-safe storage mechanism to handle concurrent access.
*   Easy Integration: Seamlessly integrates with your Swift projects using Swift's macro system.
*   Reset Capability: Provides functions to reset the cache for specific `memoized` functions.

Just a heads-up, while this implementation gets the job done with current Swift macros, Swift 5.10+ brings in preamble macros ([SE-0402](https://github.com/apple/swift-evolution/blob/main/proposals/0402-preamble-macros.md)). These could offer different ways to handle the setup part of the macro down the road, potentially making things a bit neater.

## Installation

To integrate MemoizationMacros into your Swift project, follow these steps:

1.  Add the Package

    Add `Memoization` to your project's dependencies in your Package.swift:

    ```swift
    dependencies: [
        .package(url: "https://github.com/brunogama/Memoization.git", from: "0.0.1"), // Adjust version as needed
    ],
    ```

2.  Import the Module

    ```swift
    import Memoization
    ```

## Usage

Annotate your functions with the `@memoized` macro to enable `memoization`.

```swift
import Memoization

class Calculator {
    @memoized
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
}