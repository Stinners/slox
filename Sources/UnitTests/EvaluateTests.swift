
import XCTest 
import Nimble 

@testable import libslox

func expectResult(source: String, expected: Primitive) throws {
    let tokens = try Scanner(source: source).scanTokens()
    let ast = Parser(tokens: tokens).parse()!
    let result = try ast.evaluate()
    expect(result).to(equal(expected))
}

final class EvaluateTests: XCTestCase {
    func testPrimitives() throws {
        try expectResult(source: "1.0", expected: .Number(1.0))
        try expectResult(source: "true", expected: .Boolean(true))
        try expectResult(source: "false", expected: .Boolean(false))
        try expectResult(source: "nil", expected: .Nil)
        try expectResult(source: "\"foo\"", expected: .String("foo"))
    }

    func testSimpleArithmetic() throws {
        try expectResult(source: "1 + 1", expected: .Number(2.0))
        try expectResult(source: "1 - 1", expected: .Number(0.0))
        try expectResult(source: "5 * 3", expected: .Number(15.0))
        try expectResult(source: "6 / 3.0", expected: .Number(2.0))
        try expectResult(source: "6 +  - 3.0", expected: .Number(3.0))
        try expectResult(source: "6 + 2 * 3", expected: .Number(12.0))
        try expectResult(source: "2 * 3 + 6", expected: .Number(12.0))
        try expectResult(source: "2 * (3 + 6)", expected: .Number(18.0))
    }

    func testComparisons() throws {
        try expectResult(source: "1 == 1", expected: .Boolean(true))
        try expectResult(source: "1 != 1", expected: .Boolean(false))
        try expectResult(source: "2 < 2", expected: .Boolean(false))
        try expectResult(source: "2 < 3", expected: .Boolean(true))
        try expectResult(source: "2 <= 2", expected: .Boolean(true))
        try expectResult(source: "10 > 10", expected: .Boolean(false))
        try expectResult(source: "10 >= 10", expected: .Boolean(true))
    }

}
