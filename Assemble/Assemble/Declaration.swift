//
//  Declaration.swift
//  Assemble
//
//  Created by Jaden Geller on 10/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

struct TypeDeclaration: Serializable {
    let identifier: LocalIdentifier
    let type: Type
    
    var serialization: String {
        return tokens(
            identifier,
            "=",
            "type",
            type
        )
    }
}

struct GlobalDeclaration: Serializable {
    let identifier: GlobalIdentifier
    let type: Type
    let value: Value
    
    var serialization: String {
        return tokens(
            identifier,
            "=",
            "global",
            type,
            value
        )
    }
}