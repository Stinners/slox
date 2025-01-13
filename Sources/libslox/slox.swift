// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class Interpreter {
    var hadError = false 

    public init() {}

    func report(at line: Int, where: String, message: String) {
        print("[line \(line)] Error \(`where`): \(message)")
        hadError = true
    }


    func error(at line: Int, about: String) {
        report(at: line, where: "", message: about) 
    }


    func run(program: String) {
        let scanner = Scanner(source: program)
        do {
            let tokens = try scanner.scanTokens()

            for token in tokens {
                print(token)
            }
        }
        catch let LoxError.ScannerError(line: line, pos: _, message: message) {
            error(at: line, about: message)
        }
        catch {
            print("Unrecognized error \(error)")
        }

    }


    func runFile(path: String) {
        do {
            let contents = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            run(program: contents)
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
