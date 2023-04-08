import Foundation

public enum LibraryError: Error {
    case parsingFailure
}

public func add(_ data: Data) throws -> Int {
    guard let string = String(data: data, encoding: .utf8) else {
        throw LibraryError.parsingFailure
    }
    return try add(string)
}


public func add(_ string: String) throws -> Int {
    let scanner = Scanner(string: string)
    guard let lhs = scanner.scanDouble() else {
        throw LibraryError.parsingFailure
    }
    guard scanner.scanString("+") != nil else {
        throw LibraryError.parsingFailure
    }
    guard let rhs = scanner.scanDouble() else {
        throw LibraryError.parsingFailure
    }
    return Int(lhs) + Int(rhs)
}
