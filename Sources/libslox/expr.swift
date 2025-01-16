import Foundation

// We could use swift's 'Any' type here, but it's more
// interetsing to do it ourselves
enum Primitive: CustomStringConvertible, Equatable {
    case String(String)
    case Number(Float)
    case Boolean(Bool)
    case Nil

    var description: String {
        return switch self {
            case let .String(str):   str
            case let .Number(num):   num.description
            case let .Boolean(bool): bool.description
            case     .Nil:           "nil"
        }
    }

    // =========== Arithmetic Operators ================= //

    func plus(_ other: Primitive) -> Primitive? {
        return switch (self, other) {
            case let (.Number(a), .Number(b)): .Number(a+b)
            case let (.String(a), .String(b)): .String(a+b)
            default: .none
        }
    }
    func minus(_ other: Primitive) -> Primitive? {
        return switch (self, other) {
            case let (.Number(a), .Number(b)): .Number(a-b)
            default: .none
        }
    }
    func times(_ other: Primitive) -> Primitive? {
        return switch (self, other) {
            case let (.Number(a), .Number(b)): .Number(a*b)
            default: .none
        }
    }
    func divide(_ other: Primitive) -> Primitive? {
        return switch (self, other) {
            case let (.Number(a), .Number(b)): .Number(a/b)
            default: .none
        }
    }

    // =========== Truth Values ================= //

    func truth() -> Primitive {
        return switch self {
            case .Nil, .Boolean(false): .Boolean(false)
            default:                    .Boolean(true)
        }
    }

    func not() -> Primitive {
        return switch self {
            case .Nil, .Boolean(false): .Boolean(true)
            default:                    .Boolean(false)
        }
    }

    // =========== Logical Operators ================= //

    // TODO: make these special functions which take generic expressions
    // (rather than SObjects) and only evalute them when needed
    func and(_ other: Primitive) -> Primitive {
        switch (self.truth(), other.truth()) {
            case (.Boolean(true), .Boolean(true)): .Boolean(true)
            default:                               .Boolean(false)
        }
    }

    func or(_ other: Primitive) -> Primitive {
        switch (self.truth(), other.truth()) {
            case (.Boolean(false), .Boolean(false)): .Boolean(false)
            default:                                 .Boolean(true)
        }
    }

    // =========== Comparison Operators ================= //

    func equal(_ other: Primitive) -> Primitive {
        if self == other {
            return .Boolean(true)
        } else {
            return .Boolean(false)
        }
    }
    func not_equal(_ other: Primitive) -> Primitive {
        return self.equal(other).not()
    }

    func less_than(_ other: Primitive) -> Primitive? {
        switch (self, other) {
            case let (.Number(a), .Number(b)): .Boolean(a<b)
            case let (.String(a), .String(b)): .Boolean(a<b)
            default: .none
        }
    }
    func less_than_equal_to(_ other: Primitive) -> Primitive? {
        self.less_than(other).map { $0.or(self.equal(other)) }
    }
    func greater_than(_ other: Primitive) -> Primitive? {
        self.less_than(other).map { $0.not() }
    }
    func greater_than_equal_to(_ other: Primitive) -> Primitive? {
        self.greater_than(other).map { $0.or(self.equal(other)) }
    }

}

protocol Expr {
    func display() -> String
    func evaluate() throws -> Primitive
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


func raiseRuntimeError(result: Primitive?, token: Token, message: String) throws -> Primitive {
    if case let .some(val) = result {
        return val
    }
    else {
        throw LoxError.RuntimeError(token: token, message: message)
    }
}

struct Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr

    func display() -> String { parenthesize(name: op.lexeme, exprs: left, right) }

    func evaluate() throws -> Primitive {
        let leftObj = try left.evaluate()
        let rightObj = try right.evaluate()

        let result: Primitive? = switch op.type {
            // Arithmetic Operators
            case .MINUS: leftObj.minus(rightObj)
            case .PLUS:  leftObj.plus(rightObj)
            case .SLASH: leftObj.divide(rightObj)
            case .STAR:  leftObj.times(rightObj)

            // Comparison operators
            case .LESS:          leftObj.less_than(rightObj)
            case .LESS_EQUAL:    leftObj.less_than_equal_to(rightObj)
            case .GREATER:       leftObj.greater_than(rightObj)
            case .GREATER_EQUAL: leftObj.greater_than_equal_to(rightObj)

            // Logical Operators
            // TODO impliment short circuiting logical operators
            case .AND: leftObj.and(rightObj)
            case .OR: leftObj.or(rightObj)

            default: fatalError("Invalid binary operator")
        }
        return try raiseRuntimeError(
            result: result,
            token: op,
            message: "Operator \(op.lexeme) not valid for \(leftObj) and \(rightObj)"
        )
    }
}

struct Grouping: Expr {
    let expression: Expr

    func display() -> String { parenthesize(name: "group", exprs: expression) }

    func evaluate() throws -> Primitive {
        return try expression.evaluate()
    }
}

struct Literal: Expr {
    let value: Primitive

    init(token: Token) {
        value = switch token.type {
            case let .STRING(str): .String(String(str))
            case let .NUMBER(num): .Number(num)
            case     .TRUE:        .Boolean(true)
            case     .FALSE:       .Boolean(false)
            case     .NIL:         .Nil
            default:               fatalError("Invalid literal token: \(token)")
        }
    }

    func display() -> String { value.description }

    func evaluate() throws -> Primitive {
        return value
    }
}

struct Unary: Expr {
    let op: Token
    let right: Expr

    func display() -> String { parenthesize(name: op.lexeme, exprs: right) }

    func evaluate() throws -> Primitive {
        let rightObj = try right.evaluate()

        let result = switch op.type {
            case .MINUS: Primitive.Number(0).minus(rightObj)
            case .BANG: rightObj.not()
            default: fatalError("Invalid Unary operator \(op)")
        }
        return try raiseRuntimeError(
            result: result,
            token: op,
            message: "Unary Operator \(op.lexeme) not valid for \(rightObj)"
        )
    }
}

func interpret(expr: Expr) throws {
    do {
        let result = try expr.evaluate()
        print(result)
    }
    catch {
        print("Unrecognized error in evaluator \(error)")
        abort()
    }
}
