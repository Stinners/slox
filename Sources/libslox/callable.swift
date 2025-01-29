
protocol LoxCallable {
    func call(_ context: Context, arguments: Array<Primitive>) throws -> Primitive
}

func makeCallable(_ value: Primitive) throws -> LoxCallable {
    switch value {
        default: throw LoxError.RuntimeError(token: Token(type: .NIL, lexeme: "", line: 0), message: "Value: \(value) is not callable")
    }
}
