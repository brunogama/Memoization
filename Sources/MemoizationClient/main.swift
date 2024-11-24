import Memoization

class A {
    @memoized
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 {
            return n
        }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
}

let a = A()
print(a.memoizedFibonacci(10))

print(a.memoizedFibonacci(10))
