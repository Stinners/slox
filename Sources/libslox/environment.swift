
class Environment {
    var values: Dictionary<String, Primitive>;

    init() {
        values = [:]
    } 

    func define(_ name: String, toBe newValue: Primitive) {
        values[name] = newValue
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
