
public protocol Expr {
    func display() -> String
}

public func parenthesize(name: CustomStringConvertible, exprs: Expr...) -> String {
    var str = "("

    for expr in exprs {
        str.append(" ")
        str.append(expr.display())
    }
    str.append(")")

    return str 
}


public struct Binary: Expr {
    public let left: Expr
    public let op: Token 
    public let right: Expr

    public func display() -> String { parenthesize(name: op.lexeme, exprs: left, right) }
}

public struct Grouping: Expr {
    public let expression: Expr

    public func display() -> String { parenthesize(name: "group", exprs: expression) }
}

// TODO add constructor which checks that 
// only valid literals can be included
public struct Literal: Expr {
    public let value: Token

    public func display() -> String { String(value.lexeme) }
}

public struct Unary: Expr {
    public let op: Token
    public let right: Expr

    public func display() -> String { parenthesize(name: op.lexeme, exprs: right) }
}
