import Foundation 

protocol Stmt {
    func evaluate() throws
}

struct Print: Stmt {
    let expression: Expr

    func evaluate() throws {
        let result = try expression.evaluate()
        print(result)
    }
}

struct Expression: Stmt {
    let expression: Expr

    func evaluate() throws {
        let _ = try expression.evaluate()
    }
}

struct Var: Stmt {
    let name: Token 
    let initializer: Expr?

    func evaluate() throws {}
}
