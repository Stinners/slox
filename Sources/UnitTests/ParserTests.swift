
import XCTest 
import Nimble 

@testable import libslox 

func parse(_ source: String) throws -> String {
    let tokens = try Scanner(source: source).scanTokens()
    let ast = Parser(tokens: tokens).parse()
    return ast!.display()
}

func expectString(source: String, expected: String) throws {
    let actual = try parse(source)
    expect(actual).to(equal(expected))
}

final class ParserTests: XCTestCase {

    func testLiterals() throws {
        try expectString(source: "12", expected: "12.0")
        try expectString(source: "true", expected: "true")
        try expectString(source: "false", expected: "false")
        try expectString(source: "nil", expected: "nil")

        try expectString(source: "\"test\"", expected: "test")
        try expectString(source: "\"test \n foo\"", expected: "test \n foo")
        try expectString(source: "\"nil\"", expected: "nil")
    }

    func testGrouping() throws {
        try expectString(source: "(1)", expected: "(group 1.0)")
        try expectString(source: "(((1)))", expected: "(group (group (group 1.0)))")
    }

    func testUnary() throws {
        try expectString(source: "!true", expected: "(! true)")
        try expectString(source: "-1", expected: "(- 1.0)")
    }

    func testBinary() throws {
        try expectString(source: "1 + 1", expected: "(+ 1.0 1.0)")
        try expectString(source: "1 <= 1", expected: "(<= 1.0 1.0)")
        try expectString(source: "10.0 / 5", expected: "(/ 10.0 5.0)")
    }

    func testPrecidence() throws {
        try expectString(source: "1 + 4 * 10", expected: "(+ 1.0 (* 4.0 10.0))")
        try expectString(source: "1 * 4 + 10", expected: "(+ (* 1.0 4.0) 10.0)")
        try expectString(source: "1 * - 4", expected: "(* 1.0 (- 4.0))")
    }

}
