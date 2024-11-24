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
        let storage = "memoized\(capitalizedFuncName)Storage"
        let parameterClause = signature.parameterClause
        let source = """

        private var \(storage) = MemoizeStorage<\(returnTypeName)>()

        func memoized\(capitalizedFuncName)(_ n: Int) -> \(returnTypeName) {
            if let cachedResult = \(storage).getValue(for: CacheKey(n)) {
                return cachedResult
            }
            let result = fibonacci(n)
            \(storage)[CacheKey(n)] = CacheResult(result)
            return result
        }

        func resetMemoizedFibonacci() {
            \(storage).clear()
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

enum MacroError: Error, CustomStringConvertible {
    case misuse(String)
    
    var description: String {
        switch self {
        case .misuse(let message):
            return message
        }
    }
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
