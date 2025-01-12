enum LoxError: Error {
    case ScannerError(line: Int, pos: Int, message: String)
}

