import Foundation


enum TokenType: Equatable, Sendable {
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

  // We want a way to ignore the associated value in cases 
  // where one exists
  func sameType(as other: TokenType) -> Bool {
      switch  (self, other) {
          case (.IDENTIFIER, .IDENTIFIER): return true
          case (.STRING, .STRING):         return true
          case (.NUMBER, .NUMBER):         return true
          default:                         return self == other
      }
  }

}

struct Token: CustomStringConvertible {
    var type: TokenType
    var lexeme: Substring
    var line: Int
    
    var description: String {
        return "[\(type) '\(lexeme)']"
    }
}

let keywords: [Substring: TokenType] = [
    "and":    .AND,
    "class":  .CLASS,
    "else":   .ELSE,
    "false":  .FALSE,
    "for":    .FOR,
    "fun":    .FUN,
    "if":     .IF,
    "nil":    .NIL,
    "or":     .OR,
    "print":  .PRINT,
    "return": .RETURN,
    "super":  .SUPER,
    "this":   .THIS,
    "true":   .TRUE,
    "var":    .VAR,
    "while":  .WHILE,
]


class Scanner {
    var source: String
    var tokens: Array<Token> = []

    // These variables are used for error reporting
    // and map to an intutive idea of a character 
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

        // Handle empty strings
        if input.startIndex == input.endIndex {
            endIdx = startIdx
        } else {
            endIdx = source.index(before: input.endIndex)
        }
    }

    func canReadMore() -> Bool {
        return idx < endIdx
    }

    func foundChar(c: Character) -> Bool {
        switch peek() {
            case .some(c): true
            case .none: true 
            default: false
        }
    }

    // We want it so that calling advance repeatedly will return every character 
    // in the string 
    func advance() -> Bool {
        if canReadMore() {
            idx = source.index(after: idx)
            linePos += 1 
            if source[idx] == "\n" {
                line += 1
                linePos = 0
            }
            return true 
        } else {
            return false
        }
    }

    func peek() -> Character? {
        if canReadMore() {
            return source[source.index(after: idx)]
        } else {
            return Optional.none
        }
    }

    func peekNext() -> Character? {
        if canReadMore() { 
            let nextIdx = source.index(after: idx) 
            if nextIdx < endIdx {
                return source[source.index(after: nextIdx)]
            }
        }
        return Optional.none
    }


    func match(with expected: Character) -> Bool {
        let isMatch = peek().map { nextChar in nextChar == expected } ?? false

        if isMatch {
            let _ = advance()
        }

        return isMatch
    }


    // Scanning should end with the index on the last char 
    // of the current token
    func addToken(_ type: TokenType) {
        let text = source[startIdx...idx]
        let token = Token(type: type, lexeme: text, line: line)
        tokens.append(token)
    }

    func scanUntil(a char: Character, stopBefore: Bool) {
        while !foundChar(c: char) {
            let _ = advance() 
        }

        if !stopBefore {
            let _ = advance()
        }
    }

    func scanString() throws {
        scanUntil(a: "\"", stopBefore: false) 
        
        if source[idx] != "\"" {
            throw LoxError.ScannerError(line: line, pos: linePos, message: "Unterminated string")
        }
        
        let strStart = source.index(after: startIdx) 
        let strEnd = source.index(before: idx) 
        let litString = source[strStart...strEnd]
        addToken(TokenType.STRING(litString))
    }

    
    func isDigit(_ c: Character) -> Bool {
        return c.isASCII && c.isNumber
    }

    func isIdentifierStart(_ c: Character) -> Bool {
        return c.isLetter || c == "_"
    }

    func isIdentifierInner(_ c: Character) -> Bool {
        return isIdentifierStart(c) || isDigit(c)
    }

    func scanNumber() {
        while isDigit(peek() ?? " ") {
           let _ = advance()
        }

        // Skip past dot if it exists
        if (peek() == ".") && isDigit(peekNext() ?? " ") {
            let _ = advance()
        }

        while isDigit(peek() ?? " ") {
           let _ = advance()
        }

        let numberLiteral = Float(source[startIdx...idx])!
        addToken(.NUMBER(numberLiteral))
    }

    func scanIdentifier() {
        while isIdentifierInner(peek() ?? " ") {
            let _ = advance()
        }
        //while isIdentifierInner(source[idx]) && advance() {}

        let text = source[startIdx...idx]
        let type = keywords[text] ?? .IDENTIFIER(text)
        addToken(type)
    }


    func scanToken() throws {
        let char = source[idx]
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
                    scanUntil(a: "\n", stopBefore: false)
                }
                else {
                    addToken(TokenType.SLASH)
                }

            case "\"": try scanString()

            // Ignoring whilespace 
            case "\r", "\n", " ": return 

            default: 
                if isDigit(char) {
                    scanNumber()
                }
                else if isIdentifierStart(char) {
                    scanIdentifier()
                }
                else {
                    print(char)
                    throw LoxError.ScannerError(line: line, pos: linePos, message: "Invalid character \(char)")
                }
        }
    }

    func scanTokens() throws -> Array<Token> {
        if source != "" {
            repeat {
                startIdx = idx
                try scanToken()
            } while advance()
        }

        tokens.append(Token(type: TokenType.EOF, lexeme: "", line: line))
        
        return tokens
    }
}
