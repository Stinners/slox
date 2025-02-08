enum LoxError: Error {
    case ScannerError(line: Int, pos: Int, message: String)
    case ParserError(token: Token, message: String)
    case RuntimeError(token: Token, message: String)
    case DoReturn

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

            case .DoReturn:
                return "Return Statement - this should never reach the top level"
        }
    }
}

func runtimeError(message: String) -> LoxError {
    LoxError.RuntimeError(token: Token(type: .NIL, lexeme: "", line: 0), message: message)
}

