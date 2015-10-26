//
//  BasicBlock.swift
//  Assemble
//
//  Created by Jaden Geller on 10/23/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

private func function(name: String, _ arguments: Value...) -> String {
    return tokens(name, list(arguments.map(typed)))
}

extension Type {
    internal func typeassert(value: Value) {
        assert(
            typecheck(value.type),
            tokens("Expected type", self, "but found type", value.type)
        )
    }
}

public struct BasicBlock: Serializable {
    public let label: String // should be optional
    public let instructions: [InstructionType]
    public let terminator: Terminator
    
    public var identifier: LocalIdentifier {
        return LocalIdentifier(type: LabelType(), name: label)
    }
    
    public var serialization: String {
        return lines(
            concat(label, ":"),
            indent(instructions.map{ $0 }),
            indent(terminator)
        )
    }
}

public protocol InstructionType: Serializable { }

public struct LocalAssignment: InstructionType {
    public let identifier: LocalIdentifier
    public let instruction: Instruction
    
    internal init(name: String, instruction: Instruction) {
        self.identifier = LocalIdentifier(type: instruction.type, name: name)
        self.instruction = instruction
    }
    
    public var serialization: String {
        return tokens(identifier, "=", instruction)
    }
}
func assign(name: String, instruction: Instruction) -> LocalAssignment {
    return LocalAssignment(name: name, instruction: instruction)
}

public struct Instruction: InstructionType {
    public let type: Type
    public let serialization: String
    
    private init(_ type: Type, _ serialization: String) {
        self.type = type
        self.serialization = serialization
    }
}

private func binary(name: String, _ typeOfType: Type.Type)(type: Type, lhs: Value, rhs: Value) -> Instruction {
    assert(type.dynamicType == typeOfType)
    type.typeassert(lhs)
    type.typeassert(rhs)
    return Instruction(type, tokens(name, type, list(lhs, rhs)))
}

public let add = binary("add", IntegerType.self)
public let fadd = binary("fadd", FloatingPointType.self)
public let sub = binary("sub", IntegerType.self)
public let fsub = binary("fsub", FloatingPointType.self)
public let mul = binary("mul", IntegerType.self)
public let fmul = binary("fmul", FloatingPointType.self)
public let udiv = binary("udiv", IntegerType.self)
public let sdiv = binary("sdiv", IntegerType.self)
public let fdiv = binary("fdiv", FloatingPointType.self)
public let urem = binary("urem", IntegerType.self)
public let srem = binary("srem", IntegerType.self)
public let frem = binary("frem", FloatingPointType.self)

public let shl = binary("shl", IntegerType.self)
public let lshl = binary("lshl", IntegerType.self)
public let ashr = binary("ashr", IntegerType.self)
public let and = binary("and", IntegerType.self)
public let or = binary("or", IntegerType.self)
public let xor = binary("xor", IntegerType.self)

public struct Terminator: Serializable {
    public let serialization: String
    
    private init(_ serialization: String) {
        self.serialization = serialization
    }
}

public func ret(value: Value) -> Terminator {
    return Terminator(function("ret", value))
}

public func br(condition condition: Value, trueLabel: Value, falseLabel: Value) -> Terminator {
    IntegerType(size: 1).typeassert(condition)
    LabelType().typeassert(trueLabel)
    LabelType().typeassert(falseLabel)

    return Terminator(function("br", condition, trueLabel, falseLabel))
}

public func br(destination destination: Value) -> Terminator {
    LabelType().typeassert(destination)
    
    return Terminator(function("br", destination))
}


public func `switch`(value: Value, defaultDestination: Value, cases: [(value: Value, destination: Value)]) -> Terminator {
    LabelType().typeassert(defaultDestination)
    cases.forEach{
        value.type.typeassert($0.value)
        LabelType().typeassert($0.destination)
    }
    
    // TODO: It'd be nice if the cases were multi-line aligned.
    return Terminator(tokens(
        "switch",
        list(typed(value), typed(defaultDestination)),
        "[",
        tokens(cases.map{ list(typed($0.value), typed($0.destination)) }),
        "]"
    ))
}

public let unreachable = Terminator("unreachable")



