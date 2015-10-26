//
//  Transcriber.swift
//  Transcriber
//
//  Created by Jaden Geller on 10/23/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

extension SequenceType where SubSequence: SequenceType {
    func reduce1(@noescape combine: (Self.Generator.Element, Self.Generator.Element) throws -> Self.Generator.Element) rethrows -> Self.Generator.Element? {
        var generator = generate()
        var result = generator.next()
        while let next = generator.next() {
            result = try combine(result!, next)
        }
        return result
    }
}

extension String {
    func split(@noescape condition: Character throws -> Bool) rethrows -> [String] {
        return try characters.split(isSeparator: condition).map{ String($0) }
    }
    
    func split(character: Character) -> [String] {
        return split{ $0 == character }
    }
}

extension String: Serializable {
    public var serialization: String { return self }
}

public protocol Serializable {
    var serialization: String { get }
}

public func delimit(delimiter: String)(_ values: [String]) -> String {
    return values.reduce1 { result, new in
        result + delimiter + new
    } ?? ""
}

// Duplicate definition required because of how protocols work ._.
// More efficient then mapping the array to existential type first
public func delimit<S: Serializable>(delimiter: Serializable)(_ values: [S]) -> String {
    return delimit(delimiter.serialization)(values.map { $0.serialization })
}

public func delimit(delimiter: Serializable)(_ values: [Serializable]) -> String {
    return delimit(delimiter.serialization)(values.map { $0.serialization })
}

public func delimit(delimiter: Serializable)(_ values: Serializable...) -> String {
    return delimit(delimiter)(values)
}

public func concat<S: Serializable>(values: [S]) -> String {
    return delimit("")(values)
}

public func concat(values: [Serializable]) -> String {
    return delimit("")(values)
}

public func concat(values: Serializable...) -> String {
    return delimit("")(values)
}

public func lines<S: Serializable>(values: [S]) -> String {
    return delimit("\n")(values)
}

public func lines(values: [Serializable]) -> String {
    return delimit("\n")(values)
}

public func lines(values: Serializable...) -> String {
    return lines(values)
}

public func tokens<S: Serializable>(values: [S]) -> String {
    return delimit(" ")(values)
}

public func tokens(values: [Serializable]) -> String {
    return delimit(" ")(values)
}

public func tokens(values: Serializable...) -> String {
    return tokens(values)
}

public func indent<S: Serializable>(values: [S]) -> String {
    return lines(values.flatMap{ $0.serialization.split("\n") }.map{ "  " + $0 })
}

public func indent(values: [Serializable]) -> String {
    return lines(values.flatMap{ $0.serialization.split("\n") }.map{ "  " + $0 })
}

public func indent(values: Serializable...) -> String {
    return lines(values.flatMap{ $0.serialization.split("\n") }.map{ "  " + $0 })
}

public func list<S: Serializable>(values: [S]) -> String {
    return delimit(", ")(values)
}

public func list(values: [Serializable]) -> String {
    return delimit(", ")(values)
}

public func list(values: Serializable...) -> String {
    return delimit(", ")(values)
}

