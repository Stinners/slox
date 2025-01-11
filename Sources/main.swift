// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation




class Interpreter {
    var hadError = false 

    func report(at line: Int, where: String, message: String) {
        print("[line \(line)] Error \(`where`): \(message)")
        hadError = true
    }


    func error(at line: Int, about: String) {
        report(at: line, where: "", message: about) 
    }


    func run(program: String) {
        let scanner = Scanner(source: program)
        let tokens = scanner.scanTokens()

        for token in tokens {
            print(token)
        }
    }


    func runFile(path: String) {
        do {
            let contents = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            run(program: contents)
            if hadError { exit(65) } 
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

    func main() {
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

Interpreter().main()
