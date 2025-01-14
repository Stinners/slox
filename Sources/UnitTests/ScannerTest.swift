
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

    func testCanNumbers() throws {
        let scanner = Scanner(source: "1 1.23")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .NUMBER(1.0), lex: "1"),
            (type: .NUMBER(1.23), lex: "1.23"),
        ])
    }

    func testCanScanDoubleCharacters() throws {
        let scanner = Scanner(source: "!= == /")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .BANG_EQUAL, lex: "!="),
            (type: .EQUAL_EQUAL, lex: "=="),
            (type: .SLASH, lex: "/"),
        ])
    }

    func testHandlesComments() throws {
        let scanner = Scanner(source: "+ //some comment\n +")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .PLUS, lex: "+"),
            (type: .PLUS, lex: "+"),
        ])
    }

    func testHandlesNewlines() throws {
        let scanner = Scanner(source: "+ \n +")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .PLUS, lex: "+"),
            (type: .PLUS, lex: "+"),
        ])
    }

    func testHandlesSimpleStrings() throws {
        let scanner = Scanner(source: "\"foo\" \"bar 'baz\"")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .STRING("foo"), lex: "\"foo\""),
            (type: .STRING("bar 'baz"), lex: "\"bar 'baz\""),
        ])
    }

    func testHandlesIdentifiers() throws {
        let scanner = Scanner(source: "foo _bar a12")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .IDENTIFIER("foo"), lex: "foo"),
            (type: .IDENTIFIER("_bar"), lex: "_bar"),
            (type: .IDENTIFIER("a12"), lex: "a12"),
        ])
    }

    func testHandlesKeywords() throws {
        let scanner = Scanner(source: "and fun class")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .AND, lex: "and"),
            (type: .FUN, lex: "fun"),
            (type: .CLASS, lex: "class"),
        ])
    }

    func testHandlesSimpleExpression() throws {
        let scanner = Scanner(source: "while count == 12 { // comment\n }")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, are: [
            (type: .WHILE, lex: "while"),
            (type: .IDENTIFIER("count"), lex: "count"),
            (type: .EQUAL_EQUAL, lex: "=="),
            (type: .NUMBER(12.0), lex: "12"),
            (type: .LEFT_BRACE, lex: "{"),
            (type: .RIGHT_BRACE, lex: "}"),
        ])
    }
}
