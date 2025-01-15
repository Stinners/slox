
protocol Expr {
    func display() -> String
}

func parenthesize(name: CustomStringConvertible, exprs: Expr...) -> String {
    var str = "(\(name)"

    for expr in exprs {
        str.append(" ")
        str.append(expr.display())
    }
    str.append(")")

    return str 
}


struct Binary: Expr {
    let left: Expr
    let op: Token 
    let right: Expr

    func display() -> String { parenthesize(name: op.lexeme, exprs: left, right) }
}

struct Grouping: Expr {
    let expression: Expr

    func display() -> String { parenthesize(name: "group", exprs: expression) }
}

// TODO add constructor which checks that 
// only valid literals can be included
struct Literal: Expr {
    let value: Token

    func display() -> String { String(value.lexeme) }
}

struct Unary: Expr {
    let op: Token
    let right: Expr

    func display() -> String { parenthesize(name: op.lexeme, exprs: right) }
}

