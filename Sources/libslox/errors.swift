enum LoxError: Error {
    case ScannerError(line: Int, pos: Int, message: String)
    case ParserError(token: Token, message: String)

    func report() -> String {
        switch self {
            case let .ScannerError(line, _, message):
                return "[line \(line)] Error: \(message)"

            case let .ParserError(token, message):
                switch token.type {
                    case .EOF: return "[line \(token.line), at end \(message)]"
                    default: return "[line \(token.line), at \(message)]"
                }
        }
    }
}


