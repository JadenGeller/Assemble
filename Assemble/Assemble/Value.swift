//
//  Value.swift
//  Assemble
//
//  Created by Jaden Geller on 10/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public protocol Value: Serializable {
    var type: Type { get }
}

public func typed(value: Value) -> Serializable {
    return tokens(value.type, value)
}

public struct BooleanConstant: Value {
    public let type: Type = IntegerType(size: 1)
    public let value: Bool
    
    public var serialization: String {
        return value ? "true" : "false"
    }
}

public struct IntegerConstant: Value {
    public let type: Type
    public let value: Int
    
    public var serialization: String {
        return value.description
    }
}

public struct FloatingPointConstant: Value {
    public let type: Type
    public let value: Float // TODO: Should this be a string?
    
    public var serialization: String {
        return value.description // TODO: This is probably wrong.
    }
}

public struct StructureConstant: Value {
    public var values: [Value]
    
    public var type: Type {
        return StructureType(memberTypes: values.map{ $0.type })
    }
    
    public var serialization: String {
        return tokens(
            "{",
            list(values.map{ value in tokens(value.type, value) }),
            "}"
        )
    }
}

public struct ArrayConstant: Value {
    public let type: Type
    public let members: [Value]
    
    init(type: Type, members: [Value]) {
        assert(members.map{ type.typecheck($0.type) }.all(),
        "Members of an array must be same type as array.")
        
        self.type = type
        self.members = members
    }
    
    public var serialization: String {
        return tokens(
            "[",
            list(members.map(typed)),
            "]"
        )
    }
}

/*

extension String {
    var ascii: [Character] {
        return utf8.map(UInt32.init).map(UnicodeScalar.init).map(Character.init)
    }
}
*/

public struct StringConstant: Value {
    public let value: String
    
    public var type: Type {
        return ArrayType(
            size: value.utf8.count,
            elementType: IntegerType(size: 8)
        )
    }
    
    public var serialization: String {
        // TODO: Escape string such that the IR can have actual string constants
        //       instead of gross arrays.
        return ArrayConstant(
            type: IntegerType(size: 8),
            members: value.utf8.map(Int.init).map { value in
                IntegerConstant(type: IntegerType(size: 8), value: value)
            }
        ).serialization
    }
}

public struct ZeroInitializerConstant: Value {
    public let type: Type
    public var serialization: String {
        return "zeroinitializer"
    }
}

public struct UndefinedConstant: Value {
    public let type: Type
    public var serialization: String {
        return "undef"
    }
}
