
import XCTest
import Nimble

import libslox

final class ScannerTest: XCTestCase {

    func checkToken(token actual: Token, hasType expected: TokenType) {
        expect(actual.type).to(equal(expected))
    }


    func testCanScanSingleCharacters() throws {
        let scanner = Scanner(source: "()")
        let tokens = try scanner.scanTokens()
        print(tokens)

        //checkToken(token: tokens[0], hasType: TokenType.LEFT_PAREN)
        /*
        checkToken(token: tokens[1], hasType: TokenType.RIGHT_PAREN)
        checkToken(token: tokens[2], hasType: TokenType.DOT)
        checkToken(token: tokens[3], hasType: TokenType.PLUS)
        checkToken(token: tokens[4], hasType: TokenType.SEMICOLON)
        */
    }
}
