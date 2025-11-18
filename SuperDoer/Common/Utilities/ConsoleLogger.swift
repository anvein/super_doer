enum ConsoleLogger {
    enum LogLevel {
        case debug, info, warning, error
        var symbol: String {
            switch self {
            case .debug: "⚙️"
            case .info: "ℹ️"
            case .warning: "⚠️"
            case .error: "🛑"
            }
        }
    }

    static func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        print("\(level.symbol) [\(level)] \(message)")
        #endif
    }

    static func warning(_ message: String) {
        Self.log(message, level: .warning)
    }

}
