//
//  Function.swift
//  Assemble
//
//  Created by Jaden Geller on 10/23/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct Function: Serializable {
    public typealias Argument = LocalIdentifier

    public let identifier: GlobalIdentifier
    public let returnType: Type
    public let arguments: [Argument]
    public let blocks: [BasicBlock]
    
    public init(name: String, returnType: Type, arguments: [Argument], blocks: [BasicBlock]) {
        self.identifier = GlobalIdentifier(
            type: FunctionType(
                returnType: returnType,
                parameterTypes: arguments.map{ $0.type }
            ),
            name: name
        )
        self.returnType = returnType
        self.arguments = arguments
        self.blocks = blocks
    }
    
    public var serialization: String {
        return lines(
            tokens(
                "define",
                returnType,
                concat(
                    identifier,
                    "(",
                    list(arguments.map(typed)),
                    ")"
                ),
                "{"
            ),
            indent(blocks.map { $0 }),
            "}"
        )
    }
}

