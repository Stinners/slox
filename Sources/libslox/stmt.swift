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
        if try condition.evaluate(context).isTruthy() {
            try thenBranch.evaluate(context)
        }
        else if elseBranch != nil {
            try elseBranch!.evaluate(context)
        }
    }
}

struct While: Stmt {
    let condition: Expr
    let body: Stmt

    func evaluate(_ context: Context) throws {
        let innerContext = context.inner()
        while try condition.evaluate(innerContext).isTruthy() { 
            try body.evaluate(innerContext)
        }
    }
}

struct Function: Stmt {
    let name: Token 
    let params: Array<Token> 
    let body: Array<Stmt>


    func evaluate(_ context: Context) throws {
        let function = LoxFunction(declaration: self)
        context.define(String(name.lexeme), toBe: .Function(function))
    }
}

struct Return: Stmt {
    let keyword: Token 
    let value: Expr 

    func evaluate(_ context: Context) throws {
        let returnVal = try value.evaluate(context)
        context.environment.setReturn(to: returnVal)
        throw LoxError.DoReturn
    }
}
