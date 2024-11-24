import SwiftCompilerPlugin
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum MemoizeMacro: PeerMacro {
    private struct FunctionInfo {
        let returnType: String
        let funcName: String
        let parameters: [(type: String, name: String, declaration: String)]

        var capitalizedFuncName: String { funcName.uppercasingFirstLetter() }

        var storageName: String { "memoized\(capitalizedFuncName)Storage" }

        var parameterClause: String { parameters.map(\.declaration).joined(separator: ", ") }

        var keyParameters: String { parameters.map(\.name).joined(separator: ", ") }
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let funcInfo = try extractFunctionInfo(from: declaration)
        let source = generateSource(from: funcInfo)
        return try parseDeclarations(from: source)
    }

    private static func extractFunctionInfo(
        from declaration: some DeclSyntaxProtocol
    ) throws -> FunctionInfo {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroError.misuse("@memoized can only be attached to functions")
        }

        let signature = funcDecl.signature
        let returnType = try extractReturnType(from: signature)
        let parameters = try extractParameters(from: signature)

        return FunctionInfo(
            returnType: returnType,
            funcName: funcDecl.name.text,
            parameters: parameters
        )
    }

    private static func extractReturnType(from signature: FunctionSignatureSyntax) throws -> String
    {
        guard let returnTypeSyntax = signature.returnClause?.type else {
            throw MacroError.misuse("@memoized requires a function with a return type")
        }
        return returnTypeSyntax.trimmed.description
    }

    private static func extractParameters(
        from signature: FunctionSignatureSyntax
    ) throws -> [(type: String, name: String, declaration: String)] {
        let parameters = signature.parameterClause.parameters
        if parameters.isEmpty {
            throw MacroError.misuse("@memoized requires at least one parameter")
        }
        return parameters.map { param in
            let paramType = param.type.trimmed.description
            let paramName = extractParameterName(from: param)
            // Use the original parameter syntax to maintain correct comma placement
            let paramDeclaration = param.description
            return (paramType, paramName, paramDeclaration)
        }
    }

    private static func extractParameterName(from parameter: FunctionParameterSyntax) -> String {
        if let secondName = parameter.secondName?.text { return secondName }
        return parameter.firstName.text == "_" ? "_" : parameter.firstName.text
    }

    private static func generateSource(from info: FunctionInfo) -> String {
        let parameterClause = info.parameterClause.trimmingCharacters(in: .whitespaces)
        
        return """
        
        private var \(info.storageName): MemoizeStorage<\(info.returnType)>? = .init()
        
        func memoized\(info.funcName.uppercasingFirstLetter())(\(parameterClause)) -> \(info.returnType) {
            let key = CacheKey(\(info.keyParameters))
            
            if let cachedResult = \(info.storageName)?.getValue(for: key) {
                return cachedResult
            }
            
            let result = \(info.funcName)(\(info.keyParameters))
            \(info.storageName)?[key] = CacheResult(result)
            return result
        }
        
        func resetCache\(info.funcName.uppercasingFirstLetter())() {
            \(info.storageName)?.clear()
        }
        """
    }

    private static func parseDeclarations(from source: String) throws -> [DeclSyntax] {
        var parser = Parser(source)
        return [DeclSyntax.parse(from: &parser)]
    }
}

@main struct MemoizationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [MemoizeMacro.self]
}

enum MacroError: Error, CustomStringConvertible {
    case misuse(String)

    var description: String {
        switch self {
        case .misuse(let message): return message
        }
    }
}

extension String {
    var startsWithUppercase: Bool {
        guard let firstCharacter = self.first else { return false }
        return firstCharacter.isUppercase
    }

    func uppercasingFirstLetter() -> String { prefix(1).uppercased() + dropFirst() }
}
