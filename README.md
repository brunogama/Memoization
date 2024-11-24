# MemoizationMacros

**Memoization** is a Swift compiler plugin that provides a `@memoized` macro for automatically memoizing function results. By leveraging Swift's powerful macro system, `@memoized` simplifies caching the results of expensive function calls, enhancing performance without boilerplate code.

## Features

* Automatic Caching: Automatically caches function results based on input parameters.
* Thread-Safe Storage: Utilizes a thread-safe storage mechanism to handle concurrent access.
* Easy Integration: Seamlessly integrates with your Swift projects using Swift's macro system.
* Reset Capability: Provides functions to reset the cache for specific `memoized` functions.
                                                                
## Installation
                                                                
To integrate MemoizationMacros into your Swift project, follow these steps:

1. Add the Package

Add `Memoization` to your project's dependencies in your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/brunogama/Memoization.git", from: "0.0.1"),
],
```

2. Import the Module

```swift
import MemoizationMacros
```

## Usage

Annotate your functions with the `@memoized` macro to enable `memoization`.

```swift
class Calculator {
    @memoized
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
}
```

In this example:

The `@memoized` macro automatically caches the results of the fibonacci function.
Subsequent calls with the same parameter and retrieve the result from the cache, avoiding redundant computations.

**Generated code:**

```swift
class Calculator {
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
```

In the future I will add policies for automatic cacche invalidation. Such as notification of low memory or stall data, timeouts and so on. Suggestions are welcome.

## How It Works
The `@memoized` macro processes annotated functions and generates additional code to handle caching:

1. Function Analysis: Extracts the function's name, return type, and parameters.
2. Cache Key Generation: Creates a unique key based on the function's parameters.
3. Storage Creation: Initializes a storage mechanism (MemoizeStorage) to hold cached results.
4. Memoized Function: Generates a memoized version of the function that:
5. Checks if the result exists in the cache.
6. Returns the cached result if available.
7. Computes, caches, and returns the result if not.
8. Cache Reset Function: Generates a function to clear the cache for the specific memoized function.

## Requirements

Swift Version: Requires Swift 5.9 or later.

Platform Support: Compatible with all platforms supported by Swift.

Swift Compiler: Utilizes Swift's macro system; ensure your compiler supports macros.

## Contributing

Contributions are welcome! Please follow these steps:

Fork the Repository
Create a Feature Branch
```bash
git checkout -b feature/YourFeature
# Commit Your Changes
```

```bash
git commit -m "Add YourFeature"
# Push to the Branch
```

```bash
git push origin feature/YourFeature
```

## License

This project is licensed under the MIT License.