
class Environment {
    var values: Dictionary<String, Primitive>;

    init() {
        values = [:]
    } 

    func define(_ name: String, toBe newValue: Primitive) {
        values[name] = newValue
    }

    func assign(_ name: Token, toBe newValue: Primitive) throws {
        let nameStr = String(name.lexeme)
        if values[nameStr] != nil {
            throw LoxError.RuntimeError(
                token: name, 
                message: "Assigning to undefined variable '" + name.lexeme + "'."
            )
        }
        else {
            values[nameStr] = newValue
        }
    }

    func get(_ name: Token) throws -> Primitive {
        if let value = values[String(name.lexeme)] {
            return value
        }
        else {
            throw LoxError.RuntimeError(token: name, message: "Undefined variable '" + name.lexeme + "'.")
        }
    }
}
