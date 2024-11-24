@_exported import MemoizationCore

@attached(peer, names: prefixed(memoize))
public macro memoize() =
#externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")
