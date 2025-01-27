import Foundation

class Context {
    var environment: Environment

    init(_ environment: Environment? = nil) {
        self.environment = environment ?? Environment()
    }

    func inner() -> Context {
        let innerEnv = Environment(parent: self.environment)
        return Context(innerEnv)
    }
}

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

    func isTruthy() -> Bool {
        self.truth() == .Boolean(true)
    }

    func not() -> Primitive {
        return switch self {
            case .Nil, .Boolean(false): .Boolean(true)
            default:                    .Boolean(false)
        }
    }

    // =========== Logical Operators ================= //

    // These are here to simplify defining things like comparision operators 
    // which operate on primitives
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
        self.equal(other).not()
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
        switch (self, other) {
            case let (.Number(a), .Number(b)): .Boolean(a>b)
            case let (.String(a), .String(b)): .Boolean(a>b)
            default: .none
        }
    }
    func greater_than_equal_to(_ other: Primitive) -> Primitive? {
        self.greater_than(other).map { $0.or(self.equal(other)) }
    }
}

// ================== Short circuiting logical operators ===============//

func lazyAnd(left: Expr, right: Expr, _ context: Context) throws -> Primitive {
    let evalLeft = try left.evaluate(context)
    if case .Boolean(false) = evalLeft.truth() {
        return .Boolean(false)
    }

    let evalRight = try right.evaluate(context)
    return evalRight.truth()
}

func lazyOr(left: Expr, right: Expr, _ context: Context) throws -> Primitive {
    let evalLeft = try left.evaluate(context)
    if case .Boolean(true) = evalLeft.truth() {
        return .Boolean(true)
    }

    let evalRight = try right.evaluate(context)
    return evalRight.truth()
}

// ================== Expression Types ===============//

protocol Expr {
    func display() -> String
    func evaluate(_ context: Context) throws -> Primitive
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

    func evaluate(_ context: Context) throws -> Primitive {
        // Short circuiting operators
        switch op.type {
            case .AND: return try lazyAnd(left: left, right: right, context)
            case .OR:  return try  lazyOr(left: left, right: right, context)
            default:   break
        }

        // Else we need to evaluate both sides
        let leftVal = try left.evaluate(context)
        let rightVal = try right.evaluate(context)

        let result: Primitive? = switch op.type {
            // Arithmetic Operators
            case .MINUS: leftVal.minus(rightVal)
            case .PLUS:  leftVal.plus(rightVal)
            case .SLASH: leftVal.divide(rightVal)
            case .STAR:  leftVal.times(rightVal)

            // Comparison operators
            case .LESS:          leftVal.less_than(rightVal)
            case .LESS_EQUAL:    leftVal.less_than_equal_to(rightVal)
            case .GREATER:       leftVal.greater_than(rightVal)
            case .GREATER_EQUAL: leftVal.greater_than_equal_to(rightVal)

            case .EQUAL_EQUAL: leftVal.equal(rightVal)
            case .BANG_EQUAL:  leftVal.equal(rightVal).not()

            default: fatalError("Invalid binary operator")
        }
        return try raiseRuntimeError(
            result: result,
            token: op,
            message: "Operator \(op.lexeme) not valid for \(leftVal) and \(rightVal)"
        )
    }
}

struct Grouping: Expr {
    let expression: Expr

    func display() -> String { parenthesize(name: "group", exprs: expression) }

    func evaluate(_ context: Context) throws -> Primitive {
        return try expression.evaluate(context)
    }
}

struct Literal: Expr {
    let value: Primitive

    init(value: Primitive) {
        self.value = value
    }

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

    func evaluate(_ context: Context) throws -> Primitive {
        return value
    }
}

struct Unary: Expr {
    let op: Token
    let right: Expr

    func display() -> String { parenthesize(name: op.lexeme, exprs: right) }

    func evaluate(_ context: Context) throws -> Primitive {
        let rightObj = try right.evaluate(context)

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

struct Variable: Expr {
    let name: Token 

    func evaluate(_ context: Context) throws -> Primitive {
        return try context.environment.get(name)
    }

    func display() -> String {
        String(name.lexeme)
    }
}

struct Assign: Expr {
    let name: Token 
    let value: Expr

    func evaluate(_ context: Context) throws -> Primitive {
        let result = try value.evaluate(context)
        try context.environment.assign(name, toBe: result)
        return result
    }

    func display() -> String { "(= \(name.lexeme) \(value.display())" }
}

func interpret(expr: Expr) throws {
    let context = Context()
    do {
        let result = try expr.evaluate(context)
        print(result)
    }
    catch {
        print("Unrecognized error in evaluator \(error)")
        abort()
    }
}

