// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

func initGlobals(context: Context) {

    context.environment.define("clock", toBe: .Function(Clock()))
}

public class Interpreter {
    var hadError = false 
    var hadRuntimeError = false

    public init() {}

    func handleError(_ error: LoxError) {
        print(error.report())
        hadError = true
    }

    func run(program: String) {
        let scanner = Scanner(source: program)
        do {
            let tokens = try scanner.scanTokens()
            let parser = Parser(tokens: tokens)

            let context = Context()
            initGlobals(context: context)
            if case let .some(statemenets) = parser.parse() {
                for statemenet in statemenets {
                    try statemenet.evaluate(context)
                }
            }
        }
        catch let error as LoxError {
            if case .RuntimeError = error {
                hadRuntimeError = true
            }
            handleError(error)
        }
        catch {
            print("Unrecognized error \(error)")
            hadError = true
        }

    }


    func runFile(path: String) {
        do {
            let contents = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            run(program: contents)

            if hadError { exit(65) }
            if hadRuntimeError { exit(70) }
        }
        catch {
            print("File '\(path)' cannot be read: \(error)")
        }
    }


    func runPrompt() {
        while true {
            print("> ", terminator: "")
            let line = readLine()
            if line == "" {
                break
            }
            run(program: line!)
            hadError = false
        }
    }

    public func main() {
        let nArgs = CommandLine.arguments.count
        print(CommandLine.arguments)
        if nArgs > 2 {
            print("Usage slox [script]")
            exit(64)
        }
        else if nArgs == 2 {
            runFile(path: CommandLine.arguments[1])
        }
        else {
            runPrompt()
        }
    }
}
