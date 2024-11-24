@_exported import MemoizationCore

@attached(peer, names: arbitrary)
public macro memoized() =
    #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")
