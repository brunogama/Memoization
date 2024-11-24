import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftParser

public enum MemoizeMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard var funcDecl = declaration.as(FunctionDeclSyntax.self) else {
          throw MacroError.misuse("@memoized can only be attached to functions")
        }
        
        let signature = funcDecl.signature
        let parameterClause = signature.parameterClause
        let source = """
            \
            private var memoizedFibonacci = MemoizeStorage<Int>()

            func memoizedFibonacci(_ n: Int) -> Int {
                if let cachedResult = memoizedFibonacci.getValue(for: CacheKey(n)) {
                    return cachedResult
                }

                let result = fibonacci(n)
                memoizedFibonacci[CacheKey(n)] = CacheResult(result)
                return result
            }

            func resetMemoizedFibonacci() {
                memoizedFibonacci.clear()
            }
            """
        var parser = Parser(source)
        
        return [
            DeclSyntax.parse(from: &parser)
        ]
    }

}

@main
struct MemoizationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MemoizeMacro.self
    ]
}


enum MacroError: Error {
    case misuse(String)
}

extension String {
    var startsWithUppercase: Bool {
        guard let firstCharacter = self.first else { return false }
        return firstCharacter.isUppercase
    }
    
    func uppercasingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }
}
