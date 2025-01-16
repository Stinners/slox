
import XCTest
import Nimble

@testable import libslox

func token(type: TokenType, lexeme: String) -> Token {
    return Token(type: type, lexeme: Substring(lexeme), line: 0)
}

final class ExprPrinterTest: XCTestCase {

    func testCanPrintSimpleExpression() throws {
        let expr = Binary(
            left: Unary(
                op: token(type: .MINUS, lexeme:  "-"), 
                right: Literal(token: token(type: .NUMBER(123.0), lexeme: "123"))
            ),
            op: token(type: .STAR, lexeme: "*"),
            right: Grouping(
                expression: Literal(token: token(type: .NUMBER(45.67), lexeme: "45.67"))
            )
        )
        let actual = expr.display()
        let expected = "(* (- 123.0) (group 45.67))"

        expect(actual).to(equal(expected))
            
    }

}
