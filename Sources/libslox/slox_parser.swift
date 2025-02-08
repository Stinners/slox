// We can't call this file 'parser.swift' becuase that triggers some kind of special
// logic in the compilation process

import Foundation

class Parser {
    let tokens: Array<Token>
    var current = 0

    init(tokens: Array<Token>) {
        self.tokens = tokens
    }

    func parse() -> Array<Stmt>? {
        var statements: Array<Stmt> = []
        do {
            while !isAtEnd() {
                let statement = try statementStmt()
                statements.append(statement)
            }
            return statements
        }
        catch let error as LoxError {
            print(error.report())
            return .none
        }
        catch {
            print("Unrecognized error in parser \(error)")
            abort()
        }
    }


    // ==================== Helpers ========================

    func peek() -> Token {
        return tokens[current]
    }

    func isAtEnd() -> Bool {
        return peek().type == .EOF;
    }

    func previous() -> Token {
        return tokens[current - 1]
    }

    func advance() -> Token {
        if (!isAtEnd()) {
            current += 1
        }
        return previous()
    }

    func check(type otherToken : TokenType) -> Bool {
        if (isAtEnd()) {
            return false
        }
        return peek().type.sameType(as: otherToken)
    }

    func match(oneOf options: TokenType...) -> Token? {
        for candidate in options {
            if check(type: candidate) {
                return advance()
            }
        }
        return .none
    }

    func consume(type: TokenType, message: String) throws -> Token {
        if check(type: type) {
            return advance()
        }

        throw LoxError.ParserError(token: peek(), message: message)
    }

    // ================ Error Handling ===================

    func atStatementBoundary() -> Bool {
        let statementStart: Array<TokenType> = [
            .CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN
        ]
        return previous().type == .SEMICOLON || statementStart.contains(peek().type)
    }

    func synchronize() {
        repeat {
            let _ = advance()
        } while !(isAtEnd() || atStatementBoundary())
    }

    // ==================== Rules ========================

    // primary -> NUMBER | STRING | "true" | "false" | "nil"
    //            | "(" expression ")"
    func primary() throws -> Expr {
        if match(oneOf: .NUMBER(0), .STRING(""), .TRUE, .FALSE, .NIL) != nil {
            return Literal(token: previous())
        }

        else if match(oneOf: .IDENTIFIER("_")) != nil {
            return Variable(name: previous())
        }

        else if match(oneOf: .LEFT_PAREN) != nil {
            // TODO get expression
            let expr = try expression()
            let _ = try consume(type: .RIGHT_PAREN, message: "Expected ')' after expression")
            return Grouping(expression: expr)
        }

        else {
            throw LoxError.ParserError(token: peek(), message: "Expected literal or open parentheses")
        }
    }

    func finishCall(callee: Expr) throws -> Expr {
        var arguments: Array<Expr> = []

        if !check(type: .RIGHT_PAREN) {
            repeat {
                if arguments.count >= 255 {
                    throw LoxError.ParserError(
                        token: peek(), 
                        message: "Can't have more than 255 arguments")
                }
                arguments.append(try expression())
            } while (match(oneOf: .COMMA) != nil)
        }

        let paren = try consume(type: .RIGHT_PAREN, message: "Expect ')' after arguments")

        return Call(callee: callee, paren: paren, arguments: arguments)
    }

    func call() throws -> Expr {
        var expr = try primary()

        while true {
            if match(oneOf: .LEFT_PAREN) != nil {
                // We need this to parse higher order function expressions like func()()
                expr = try finishCall(callee: expr)
            }
            else {
                break
            }
        }

        return expr
    }

    // unary -> ( "!" | "-" ) unary
    func unary() throws -> Expr {
        if let op = match(oneOf: .BANG, .MINUS) {
            let right = try unary()
            return Unary(op: op, right: right)
        }
        else {
            return try call()
        }
    }

    // factor -> unary ( ( "/" | "* ) unary )*)
    func factor() throws -> Expr {
        var expr = try unary()

        while match(oneOf: .SLASH, .STAR) != nil {
            let op = previous();
            let right = try unary();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func term() throws -> Expr {
        var expr = try factor()

        while match(oneOf: .PLUS, .MINUS) != nil {
            let op = previous();
            let right = try factor();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func comparision() throws -> Expr {
        var expr = try term()

        while match(oneOf: .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) != nil {
            let op = previous();
            let right = try term();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func equality() throws -> Expr {
        var expr = try comparision()

        while match(oneOf: .BANG_EQUAL, .EQUAL_EQUAL) != nil {
            let op = previous();
            let right = try comparision();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func expression() throws -> Expr {
        return try equality()
    }

    func statementStmt() throws -> Stmt {
        if match(oneOf: .PRINT) != nil {
            try printStmt()
        }
        else if match(oneOf: .LEFT_BRACE) != nil {
            Block(statements: try blockStmt())
        }
        else if match(oneOf: .WHILE) != nil {
            try whileStmt()
        }
        else if match(oneOf: .FOR) != nil {
            try forStmt()
        }
        else if match(oneOf: .FUN) != nil {
            try functionStmt(kind: "function")
        }
        else if match(oneOf: .RETURN) != nil {
            try returnStmt()
        }
        else {
            try expressionStmt()
        }
    }

    func printStmt() throws -> Stmt {
        let value = try expression()
        let _ = try consume(type: .SEMICOLON, message: "Expect ';' after value")
        return Print(expression: value)
    }

    // This parses declrations e.g. var a = "foo",
    // but not assignment e.g. a = "foo"
    func varDeclarationStmt() throws -> Var {
        let ident = try consume(type: .IDENTIFIER("_"), message: "Expected Identifier")

        let initializer: Expr? = if (match(oneOf: .EQUAL) != nil) {
            try expression()
        } else {
            Optional.none
        };

        let _ = try consume(type: .SEMICOLON, message: "Expect ';' after variable declaration.")

        return Var(name: ident, initializer: initializer)
    }

    func expressionStmt() throws -> Expression {
        let value = try expression()
        let _ = try consume(type: .SEMICOLON, message: "Expect ';' after expression")
        return Expression(expression: value)
    }

    func blockStmt() throws -> Array<Stmt> {
        var statements: Array<Stmt> = []

        while !check(type: .RIGHT_BRACE) && !isAtEnd() {
            statements.append(try varDeclarationStmt())
        }

        let _ = try consume(type: .RIGHT_BRACE, message: "Expected closing brace '}' after block")
        return statements
    }

    func ifStmt() throws -> If {
        let _ = try consume(type: .LEFT_PAREN, message: "Expect '(' after 'if'.")
        let condition = try expression()
        let _ = try consume(type: .RIGHT_PAREN, message: "Expect ')' after condition")

        let thenBranch = try statementStmt() 

        let elseBranch: Stmt? = if match(oneOf: .ELSE) != nil {
            try statementStmt()
        } 
        else {
            Optional.none 
        }

        return  If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }

    func whileStmt() throws -> While {
        let _ = try consume(type: .LEFT_PAREN, message: "Expect '(' after 'while'")
        let condition = try expression()
        let _ = try consume(type: .RIGHT_PAREN, message: "Expect ')' after loop condition")
        let body = try statementStmt()

        return While(condition: condition, body: body)
    }

    // The for syntax actually desugars to a while loop 
    func forStmt() throws -> Stmt {
        let _ = try consume(type: .LEFT_PAREN, message: "Expect '(' after 'for'")

        let initializer: Stmt? = 
            if match(oneOf: .SEMICOLON) != nil {
                Optional.none
            }
            else if match(oneOf: .VAR) != nil {
                try varDeclarationStmt()
            }
            else {
                try expressionStmt()
            }

        // If there's no contion then we just set it to a literal 'true'
        // to make an infinite loop
        let condition: Expr = 
            if !check(type: .SEMICOLON) {
                try expression()
            } 
            else {
                Literal(value: .Boolean(true))
            }

        let increment: Expr? = 
            if !check(type: .RIGHT_PAREN) {
                try expression()
            }
            else {
                Optional.none
            }

        var body = try statementStmt()

        // If there's an increment expression then we want to run it each 
        // loop after the body
        if let increment {
            body = Block(statements: [
                body, 
                Expression(expression: increment)
            ])
        }

        var whileLoop: Stmt = While(condition: condition, body: body)

        // If there's an initializer, then run it once before the 
        // while loop
        if let initializer {
            whileLoop = Block(statements: [
                initializer,
                whileLoop,
            ])
        }

        return whileLoop
    }

    func functionStmt(kind: String) throws -> Function {
        let name = try consume(type: .IDENTIFIER(""), message: "Expect \(kind) name")
        let _ = try consume(type: .LEFT_PAREN, message: "Expect ( after \(kind) name")

        var parameters: Array<Token> = []

        if !check(type: .RIGHT_PAREN) {
            repeat {
                if parameters.count >= 255 {
                    throw runtimeError(message: "Cannot have more the 255 parameters")
                }
                else {
                    parameters.append(try consume(type: .IDENTIFIER(""), message: "Expected parameter name"))
                }
            } while match(oneOf: .COMMA) != nil
        }
        let _ = try consume(type: .LEFT_PAREN, message: "Expect ) after parameters")

        let _ = try consume(type: .LEFT_BRACE, message: "Expect { before \(kind) body")
        let body = try blockStmt()

        return  Function(name: name, params: parameters, body: body)
    }

    func returnStmt() throws -> Return {
        let keyword = previous()

        let value = if !check(type: .SEMICOLON) {
            try expression()
        }
        else {
            Literal(value: .Nil)
        }

        let _ = try consume(type: .SEMICOLON, message: "Expected ; after return")

        return Return(keyword: keyword, value: value)
    }

}
