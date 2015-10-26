//
//  AssembleTests.swift
//  AssembleTests
//
//  Created by Jaden Geller on 10/18/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Assemble

class AssembleTests: XCTestCase {
    
    func testMain() {
        
        let argc = Function.Argument(
            type: IntegerType(size: 32),
            name: "argc"
        )
        
        // TODO: Consider making it so implicit names are allowed.
        let subtractArgc = assign("count",
            instruction: sub(
                type: IntegerType(size: 32),
                lhs: argc,
                rhs: IntegerConstant(
                    type: IntegerType(size: 32),
                    value: 1
                )
            )
        )
        
        let main = Function(
            name: "main",
            returnType: IntegerType(size: 32),
            arguments: [
                argc,
                Function.Argument(
                    type: PointerType(PointerType(IntegerType(size: 8))),
                    name: "argv"
                )
            ],
            blocks: [
                BasicBlock(
                    label: "entry",
                    instructions: [subtractArgc],
                    terminator: ret(subtractArgc.identifier)
                )
            ]
        )
        
        print("")
        print(main.serialization)
        print("")
        
        usleep(100000)
    }

    func testComplex() {
        let res = assign("res", instruction: add(
            type: IntegerType(size: 4),
            lhs: IntegerConstant(
                type: IntegerType(size: 4),
                value: 100
            ),
            rhs: LocalIdentifier(
                type: IntegerType(size: 4),
                name: "number"
            )
        ))
        
        let res2 = assign("res2", instruction: shl(type: IntegerType(size: 4),
            lhs: res.identifier,
            rhs: IntegerConstant(
                type: IntegerType(size: 4),
                value: 2
            )
        ))
        
        let returnStatement = ret(
            StructureConstant(values: [
                IntegerConstant(
                    type: IntegerType(size: 32),
                    value: 100
                ),
                IntegerConstant(
                    type: IntegerType(size: 1),
                    value: 0
                )
            ])
        )
        
        let ifTrue = BasicBlock(label: "bleh", instructions: [], terminator: returnStatement)
        let ifFalse = BasicBlock(label: "blah", instructions: [res], terminator: returnStatement)
        
        let complex = Function(
            name: "complex",
            returnType: StructureType(memberTypes: [
                    IntegerType(size: 32),
                    IntegerType(size: 1)
                ]),
            arguments: [
                Function.Argument(
                    type: StructureType(memberTypes: [
                        IntegerType(size: 128),
                        FloatingPointType.Double
                    ]),
                    name: "x"
                ),
                Function.Argument(
                    type: ArrayType(
                        size: 10,
                        elementType: FunctionType(
                            returnType: IntegerType(size: 1),
                            parameterTypes: [IntegerType(size: 2), IntegerType(size: 1)]
                        )
                    ),
                    name: "y"
                )
            ],
            blocks: [
                BasicBlock(
                    label: "entry",
                    instructions: [
                        res,
                        res2
                    ],
                    terminator: br(
                        condition: BooleanConstant(value: true),
                        trueLabel: ifTrue.identifier,
                        falseLabel: ifFalse.identifier
                    )
                ),
                ifTrue,
                ifFalse
            ]
        )
        
        print("")
        print(complex.serialization)
        print("")

        usleep(100000)
    }
}
