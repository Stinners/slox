
import XCTest
import Nimble

import libslox

func checkToken(token actual: Token, hasType expected: TokenType) {
    expect(actual.type).to(equal(expected))
}

func checkTokens(tokens: Array<Token>, haveTypes: Array<TokenType>) {
    for (actual, expected) in zip(tokens, haveTypes) {
        expect(actual.type).to(equal(expected))
    }
    expect(tokens).to(haveCount(haveTypes.count))
}

final class ScannerTest: XCTestCase {
    func testCanHandleEmptyString() throws {
        let scanner = Scanner(source: "")
        let tokens = try scanner.scanTokens()
        checkTokens(tokens: tokens, haveTypes: [TokenType.EOF])
    }

    func testCanScanSingleCharacters() throws {
        let scanner = Scanner(source: "().+;")
        let tokens = try scanner.scanTokens()
        
        checkTokens(tokens: tokens, haveTypes: [
            TokenType.LEFT_PAREN, TokenType.RIGHT_PAREN, TokenType.DOT,
            TokenType.PLUS, TokenType.SEMICOLON, TokenType.EOF
        ])
    }
}
