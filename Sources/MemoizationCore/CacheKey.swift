//
//  CacheKey.swift
//  Memoization
//
//  Created by Bruno on 24/11/24.
//

public struct CacheKey: Hashable {
    public let parameters: [AnyHashable]

    public init<each V: Hashable>(_ parameter: repeat each V) {
        var parametersBuilding = [AnyHashable]()

        func asAnyHashable<U: Hashable>(_ value: U) {
            parametersBuilding.append(value)
        }

        repeat asAnyHashable(each parameter)

        self.parameters = parametersBuilding
    }
}
