import SwiftCompilerPlugin
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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

        let parameters = signature.parameterClause.parameters

        if parameters.isEmpty {
            throw MacroError.misuse("@memoized requires at least one parameter")
        }

        let parameterInfo = parameters.map { param -> (type: String, name: String, declaration: String) in
            let paramType = param.type.trimmed.description
            let paramName: String
            if let secondName = param.secondName?.text {
                paramName = secondName
            }
            else {
                paramName = param.firstName.text == "_" ? "_" : param.firstName.text
            }
            let paramDeclaration = param.trimmed.description
            return (paramType, paramName, paramDeclaration)
        }

        let returnType = returnTypeSyntax.trimmed.description
        let funcName = funcDecl.name.text
        let capitalizedFuncName = funcName.uppercasingFirstLetter()
        let storage = "memoized\(capitalizedFuncName)Storage"

        let parameterClause = parameters.map(\.description).joined(separator: ", ")

        let keyParams = parameterInfo.map(\.name).joined(separator: ", ")

        let source = """
            
            private var \(storage) = MemoizeStorage<\(returnType)>()
            
            func memoized\(capitalizedFuncName)(\(parameterClause)) -> \(returnType) {
                let key = CacheKey(\(keyParams))
                if let cachedResult = \(storage).getValue(for: key) {
                    return cachedResult
                }
                let result = \(funcName)(\(keyParams))
                \(storage)[key] = CacheResult(result)
                return result
            }

            func resetMemoized\(capitalizedFuncName)() {
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
