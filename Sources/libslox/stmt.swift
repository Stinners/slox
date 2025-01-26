import Foundation 

protocol Stmt {
    func evaluate(_ context: Context) throws
}

struct Print: Stmt {
    let expression: Expr

    func evaluate(_ context: Context) throws {
        let result = try expression.evaluate(context)
        print(result)
    }
}

struct Expression: Stmt {
    let expression: Expr

    func evaluate(_ context: Context) throws {
        let _ = try expression.evaluate(context)
    }
}

struct Var: Stmt {
    let name: Token 
    let initializer: Expr?

    func evaluate(_ context: Context) throws {
        let value = try initializer?.evaluate(context) ?? .Nil
        context.environment.define(String(name.lexeme), toBe: value)
    }
}

struct Block: Stmt {
    let statements: Array<Stmt>

    func evaluate(_ context: Context) throws {
        let innerContext = context.inner()

        for stmt in statements {
            try stmt.evaluate(innerContext)
        }
    }
}

struct If: Stmt {
    let condition: Expr
    let thenBranch: Stmt 
    let elseBranch: Stmt?

    func evaluate(_ context: Context) throws {
        if try condition.evaluate(context).truthy() {
            try thenBranch.evaluate(context)
        }
        else if elseBranch != nil {
            try elseBranch!.evaluate(context)
        }
    }
}
