
import XCTest
import Nimble

import libslox

func checkToken(token actual: Token, hasType expected: TokenType) {
    expect(actual.type).to(equal(expected))
}

typealias ExpectedTokens = Array<(type: TokenType, lex: String)>


func checkTokens(tokens: Array<Token>, are expectedTokens: ExpectedTokens) {
    let completeExpected = expectedTokens + [ (type: .EOF, lex: "")]

    for (actual, expected) in zip(tokens, completeExpected) {
        expect(actual.type).to(equal(expected.type))
        expect(String(actual.lexeme)).to(equal(expected.lex))
    }
    expect(tokens).to(haveCount(completeExpected.count))
}

final class ScannerTest: XCTestCase {
    func testCanHandleEmptyString() throws {
        let scanner = Scanner(source: "")
        let tokens = try scanner.scanTokens()
        checkTokens(tokens: tokens, are: [])
    }

    func testCanScanSingleCharacters() throws {
        let scanner = Scanner(source: "() .+;")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .LEFT_PAREN, lex: "("),
            (type: .RIGHT_PAREN, lex: ")"),
            (type: .DOT, lex: "."),
            (type: .PLUS, lex: "+"),
            (type: .SEMICOLON, lex: ";"),
        ])
    }

    func testCanScanDoubleCharacters() throws {
        let scanner = Scanner(source: "!=")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .BANG_EQUAL, lex: "!="),
            //(type: .EQUAL_EQUAL, lex: "=="),
            //(type: .SLASH, lex: "/"),
        ])
    }
}
