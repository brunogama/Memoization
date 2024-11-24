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
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
          throw MacroError.misuse("@memoized can only be attached to functions")
        }
        
        let signature = funcDecl.signature
        
        guard let returnTypeSyntax = signature.returnClause?.type else {
             throw MacroError.misuse("@memoized requires a function with a return type")
         }
        
        let returnTypeName = returnTypeSyntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let funcName = funcDecl.identifier.text
        let capitalizedFuncName = funcName.uppercasingFirstLetter()
        let memoizedVarName = "memoized\(capitalizedFuncName)Storage"
        let parameterClause = signature.parameterClause
        let source = """

        private var \(memoizedVarName) = MemoizeStorage<\(returnTypeName)>()

        func memoized\(capitalizedFuncName)(_ n: Int) -> Int {
            if let cachedResult = \(memoizedVarName).getValue(for: CacheKey(n)) {
                return cachedResult
            }
            let result = fibonacci(n)
            \(memoizedVarName)[CacheKey(n)] = CacheResult(result)
            return result
        }

        func resetMemoizedFibonacci() {
            memoizedFibonacciStorage.clear()
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
