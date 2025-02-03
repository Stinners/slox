import Foundation 

protocol LoxCallable {
    func call(_ context: Context, arguments: Array<Primitive>) throws -> Primitive
    func arity() -> Int
    func print() -> String
}

// Default implimentation of print
// Which defers back to the default implimentation of the concrete type
extension LoxCallable {
    func print() -> String {
        "<fn \(self)>"
    }
}

func makeCallable(_ value: Primitive) throws -> any LoxCallable {
    switch value {
        case let .Function(value): return value
        default: throw runtimeError(message: "Value: \(value) is not callable")
    }
}

struct LoxFunction: LoxCallable {
    let declaration: Function 

    func call(_ context: Context, arguments: Array<Primitive>) throws -> Primitive {
        let inner = context.inner() 

        for (param, arg) in zip(declaration.params, arguments) {
            inner.define(String(param.lexeme), toBe: arg)
        }

        try Block(statements: declaration.body).evaluate(inner)

        return .Nil
    }

    func arity() -> Int {
        declaration.params.count
    }

    func print() -> String {
        "<fn \(self.declaration.name)>"
    }
}

struct Clock: LoxCallable {

    func call(_ context: Context, arguments: Array<Primitive>) throws -> Primitive {
        .Number(Float(Date().timeIntervalSince1970))
    }

    func arity() -> Int {
        0
    }

}
