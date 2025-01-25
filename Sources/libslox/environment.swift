
class Environment {
    let parent: Environment?
    var values: Dictionary<String, Primitive>;

    init(parent: Environment? = nil) {
        values = [:]
        self.parent = parent
    } 

    func define(_ name: String, toBe newValue: Primitive) {
        values[name] = newValue
    }

    func assign(_ name: Token, toBe newValue: Primitive) throws {
        let nameStr = String(name.lexeme)

        if values[nameStr] != nil {
            values[nameStr] = newValue
        }

        // If the variable hasn't been declared in this environment then look
        // in the enclosing environment 
        else if parent != nil {
            try parent?.assign(name, toBe: newValue)
        }

        // Throw an error if the variable hasn't been declared 
        // and we're in the root enviornment (i.e. global scope)
        else {
            throw LoxError.RuntimeError(
                token: name, 
                message: "Assigning to undefined variable '" + name.lexeme + "'."
            )
        }
    }

    func get(_ name: Token) throws -> Primitive {
        if let value = values[String(name.lexeme)] {
            return value
        }
        else if parent != nil {
            return try parent!.get(name)
        }
        else {
            throw LoxError.RuntimeError(token: name, message: "Undefined variable '" + name.lexeme + "'.")
        }
    }
}
