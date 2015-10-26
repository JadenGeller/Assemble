//
//  Type.swift
//  Assemble
//
//  Created by Jaden Geller on 10/23/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

extension SequenceType where Generator.Element: BooleanType {
    func any() -> Bool {
        for x in self {
            if x { return true }
        }
        return false
    }
    
    func all() -> Bool {
        return !lazy.map{ !$0 }.any()
    }
}

extension SequenceType where Generator.Element == Type {
    func typecheck<S: SequenceType where S.Generator.Element == Type>(array: S) -> Bool {
        return zip(self, array).lazy.map{ $0.typecheck($1) }.all()
    }
}

func powerOfTwo(num: Int) -> Bool {
    return num & (num - 1) == 0
}

public protocol Type: Serializable {
    func typecheck(type: Type) -> Bool
}

public protocol PrimitiveType: Type {
    
}

public protocol FirstClassType: Type {
    
}

public protocol DerivedType: Type {
    
}

public protocol AggregateType: Type {
    
}

public struct VoidType: PrimitiveType {
    public var serialization: String {
        return "void"
    }
    
    public func typecheck(type: Type) -> Bool {
        return type is VoidType
    }
}

public struct LabelType: PrimitiveType, FirstClassType {
    public var serialization: String {
        return "label"
    }
    
    public func typecheck(type: Type) -> Bool {
        return type is LabelType
    }
}

public struct IntegerType: PrimitiveType, FirstClassType {
    public let size: Int
    
    public init(size: Int) {
        precondition(size > 0 && powerOfTwo(size))
        self.size = size
    }
    
    public var serialization: String {
        return concat("i", size.description)
    }
    
    public func typecheck(type: Type) -> Bool {
        guard let type = type as? IntegerType else { return false }
        return size == type.size
    }
}

public enum FloatingPointType: PrimitiveType, FirstClassType {
    case Half
    case Float
    case Double
    case FP128
    case X86_FP80
    case PCC_FP128
    
    public var serialization: String {
        switch self {
        case .Half:      return "half"
        case .Float:     return "float"
        case .Double:    return "double"
        case .FP128:     return "fp128"
        case .X86_FP80:  return "x86_fp80"
        case .PCC_FP128: return "pcc_fb128"
        }
    }
    
    public func typecheck(type: Type) -> Bool {
        guard let type = type as? FloatingPointType else { return false }
        return self == type
    }
}

public struct ArrayType: AggregateType {
    public let size: Int
    public let elementType: Type
    
    public var serialization: String {
        return concat("[", size.description, " x ", elementType, "]")
    }
    
    public func typecheck(type: Type) -> Bool {
        guard let type = type as? ArrayType else { return false }
        return size == type.size && elementType.typecheck(type.elementType)
    }
}

public struct StructureType: AggregateType {
    public let memberTypes: [Type]
    
    public var serialization: String {
        return tokens(
            "{",
            list(memberTypes.map{ $0 }),
            "}"
        )
    }
    
    public func typecheck(type: Type) -> Bool {
        guard let type = type as? StructureType else { return false }
        return memberTypes.typecheck(type.memberTypes)
    }
}

public struct PointerType: FirstClassType {
    public let dereferencedType: Type
    
    public init(_ dereferencedType: Type) {
        self.dereferencedType = dereferencedType
    }
    
    public var serialization: String {
        return concat(dereferencedType, "*")
    }
    
    public func typecheck(type: Type) -> Bool {
        guard let type = type as? PointerType else { return false }
        return dereferencedType.typecheck(type.dereferencedType)
    }
}

public struct FunctionType: Type {
    public let returnType: Type
    public let parameterTypes: [Type]
    
    public var serialization: String {
        return tokens(
            returnType,
            concat("(", list(parameterTypes.map { $0 }), ")")
        )
    }
    
    public func typecheck(type: Type) -> Bool {
        guard let type = type as? FunctionType else { return false }
        return returnType.typecheck(type.returnType) &&
            parameterTypes.typecheck(type.parameterTypes)
    }
}
