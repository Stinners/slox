enum LoxError: Error {
    case ScannerError(line: Int, pos: Int, message: String)
    case ParserError(token: Token, message: String)
    case RuntimeError(token: Token, message: String)

    func report() -> String {
        switch self {
            case let .ScannerError(line, _, message):
                return "[line \(line)] Error: \(message)"

            case let .ParserError(token, message):
                switch token.type {
                    case .EOF: return "[line \(token.line), at end \(message)]"
                    default: return "[line \(token.line), at \(message)]"
                }

            case let .RuntimeError(token, message):
                return "\(message)\n[line \(token.line)]"
        }
    }
}

func runtimeError(message: String) -> LoxError {
    LoxError.RuntimeError(token: Token(type: .NIL, lexeme: "", line: 0), message: message)
}

