
enum TokenType {
  // Single-character tokens.
  case LEFT_PAREN
  case RIGHT_PAREN
  case LEFT_BRACE
  case RIGHT_BRACE
  case COMMA
  case DOT
  case MINUS
  case PLUS
  case SEMICOLON
  case SLASH
  case STAR

  // One or two character tokens.
  case BANG
  case BANG_EQUAL
  case EQUAL
  case EQUAL_EQUAL
  case GREATER
  case GREATER_EQUAL
  case LESS
  case LESS_EQUAL

  // Literals.
  case IDENTIFIER(Substring)
  case STRING(Substring)
  case NUMBER(Float)

  // Keywords.
  case AND
  case CLASS
  case ELSE
  case FALSE
  case FUN
  case FOR
  case IF
  case NIL
  case OR
  case PRINT
  case RETURN
  case SUPER
  case THIS
  case TRUE
  case VAR
  case WHILE

  case EOF
}

struct Token: CustomStringConvertible {
    var type: TokenType
    var lexeme: Substring
    var line: Int
    
    var description: String {
        return "\(type) \(lexeme)"
    }
}


class Scanner {
    var source: String
    var tokens: Array<Token> = []

    // These variables are used for error reporting
    // and map to an intutive idea of a character 
    var start: Int = 0 
    var current: Int = 0 
    var line: Int = 1 
    var linePos: Int = 1

    // These variables are used for indexing into the 
    // source and map to actual byte offsets
    var idx: String.Index
    var startIdx: String.Index
    var endIdx: String.Index

    init(source input: String) {
        source = input
        idx = input.startIndex
        startIdx = idx
        endIdx = input.endIndex
    }

    func isAtEnd() -> Bool {
        return idx >= endIdx
    }

    func foundChar(c: Character) -> Bool {
        switch peek() {
            case .some(c): true
            case .none: true 
            default: false
        }
    }


    func advance() -> Character? {
        if !isAtEnd() {
            idx = source.index(after: idx) 
            let next = source[idx]

            current += 1 
            linePos += 1 
            if next == "\n" {
                line += 1
                linePos = 1 
            }

            return next
        }
        return Optional.none 
    }

    func peek() -> Character? {
        if idx < endIdx {
            let next_idx = source.index(after: idx)
            return source[next_idx]
        } else {
            return Optional.none
        }
    }

    func match(with expected: Character) -> Bool {
        let isMatch = peek().map { nextChar in nextChar == expected } ?? false

        if isMatch {
            let _ = advance()
        }

        return isMatch
    }


    func addToken(_ type: TokenType) {
        let text = source[startIdx...idx]
        let token = Token(type: type, lexeme: text, line: line)
        tokens.append(token)
    }

    func scanUntil(a char: Character) {
        while !foundChar(c: char) {
            let _ = advance() 
        }
    }

    func scanString() throws {
        scanUntil(a: "\"") 
        
        if isAtEnd() {
            throw LoxError.ScannerError(line: line, pos: linePos, message: "Unterminated string")
        }

        // Closing " 
        let _ = advance()

        let strStart = source.index(after: startIdx) 
        let strEnd = source.index(before: idx) 
        let litString = source[strStart...strEnd]
        addToken(TokenType.STRING(litString))
            
    }



    func scanToken() throws {
        let char = advance()!
        switch char {

            // Single charter tokens 
            case "(": addToken(TokenType.LEFT_PAREN) 
            case ")": addToken(TokenType.RIGHT_PAREN)
            case "{": addToken(TokenType.LEFT_BRACE)
            case "}": addToken(TokenType.RIGHT_BRACE)
            case ",": addToken(TokenType.COMMA)
            case ".": addToken(TokenType.DOT)
            case "-": addToken(TokenType.MINUS)
            case "+": addToken(TokenType.PLUS)
            case ";": addToken(TokenType.SEMICOLON)
            case "*": addToken(TokenType.STAR)

            // Two character tokens 
            case "!": 
                if match(with: "=") {
                    addToken(TokenType.BANG_EQUAL) 
                }
                else {
                    addToken(TokenType.BANG) 
                }
            case "=":
                if match(with: "=") {
                    addToken(TokenType.EQUAL_EQUAL) 
                } 
                else {
                    addToken(TokenType.EQUAL) 
                }
            case "<":
                if match(with: "=") {
                    addToken(TokenType.LESS_EQUAL)
                }
                else {
                    addToken(TokenType.LESS)
                }
            case ">":
                if match(with: "=") {
                    addToken(TokenType.GREATER_EQUAL)
                }
                else {
                    addToken(TokenType.GREATER)
                }

            // Division and comments 
            case "/":
                if match(with: "/") {
                    scanUntil(a: "\n")
                }
                else {
                    addToken(TokenType.SLASH)
                }

            case "\"": try scanString()

            // Ignoring whilespace 
            case "\r", "\n", " ": break 

            default: throw LoxError.ScannerError(line: line, pos: linePos, message: "Invalid character \(char)")
        }
    }

    func scanTokens() throws -> Array<Token> {
        while !isAtEnd() {
            start = current 
            startIdx = idx
            try scanToken()
        }

        tokens.append(Token(type: TokenType.EOF, lexeme: "", line: line))
        
        return tokens
    }
}
