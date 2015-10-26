//
//  Identifier.swift
//  Assemble
//
//  Created by Jaden Geller on 10/26/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public protocol Identifier: Value {
}

public struct GlobalIdentifier: Identifier {
    public let type: Type
    public let name: String
    
    internal init(type: Type, name: String) {
        self.type = type
        self.name = name
    }
    
    public var serialization: String {
        return concat("@", name)
    }
}

public struct LocalIdentifier: Identifier {
    public let type: Type
    public let name: String
    
    public init(type: Type, name: String) {
        self.type = type
        self.name = name
    }
    
    public var serialization: String {
        return concat("%", name)
    }
}
