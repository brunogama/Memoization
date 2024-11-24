import Memoization

class A {
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 {
            return n
        }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
}


let a = A()

print(a.fibonacci(10))
