
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
  case IDENTIFIER(String)
  case STRING(String)
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
    var lexeme: String
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


    func advance() -> Character? {
        if !isAtEnd() {
            idx = source.index(after: idx) 
            let next = source[idx]

            current += 1 
            if next == "\n" {
                line += 1
            }

            return next
        }
        return Optional.none 
    }


    func scanToken() {
        12
    }

    func scanTokens() -> Array<Token> {
        while false {
            start = current 
            startIdx = idx
        }

        tokens.append(Token(type: TokenType.EOF, lexeme: "", line: line))
        
        return tokens
    }
}
