//
//  LumberjackLogger.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 30.06.2023.
//

import CocoaLumberjackSwift

private enum LogLevel {
    case info
    case warning
    case error
    case debug
    
    var category: String {
        switch self {
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .debug: return "DEBUG"
        }
    }
    
    var symbol: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .debug: return "👨🏻‍💻"
        }
    }
}

final class LumberjackLogger {
    static let shared = LumberjackLogger()
    
    private init() {
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
//        let osLogger = DDOSLogger(subsystem: "ru.zyfunphoto.TodoLost", category: "log")
//        DDLog.add(osLogger)
    }
    
    private func logMessage(
        _ level: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard let module = URL(fileURLWithPath: file).deletingPathExtension().pathComponents.last else { return }
        let fileName = (file as NSString).lastPathComponent
        let logSymbol = level.symbol
        let formattedMessage = "\(logSymbol) [\(fileName):\(line)] \(function) - \(message)"
        
        switch level {
        case .info:
            DDLogInfo(formattedMessage)
        case .warning:
            DDLogWarn(formattedMessage)
        case .error:
            DDLogError(formattedMessage)
        case .debug:
            DDLogDebug(formattedMessage)
        }
    }
    
    func logInfoMessage(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logMessage(.info, message, file: file, function: function, line: line)
    }
    
    func logWarningMessage(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logMessage(.warning, message, file: file, function: function, line: line)
    }
    
    func logErrorMessage(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logMessage(.error, message, file: file, function: function, line: line)
    }
    
    func logDebugMessage(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logMessage(.debug, message, file: file, function: function, line: line)
    }
}
