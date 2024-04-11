import Foundation
import XCTest

/**
 A decoded key
 */
enum DecodingKey: Hashable {

    /// A decoded integer key
    case integer(Int)

    /// A decoded string key
    case string(String)
}

extension DecodingKey {

    /**
     Create a decoding key from an abstract coding key
     */
    init(key: CodingKey) {
        if let intValue = key.intValue {
            self = .integer(intValue)
        } else {
            self = .string(key.stringValue)
        }
    }
}

extension DecodingKey: ExpressibleByIntegerLiteral {

    init(integerLiteral value: IntegerLiteralType) {
        self = .integer(value)
    }
}

extension DecodingKey: ExpressibleByStringLiteral {

    init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension DecodingKey: CustomStringConvertible {

    var description: String {
        switch self {
        case .integer(let int):
            return "\(int)"
        case .string(let string):
            return string
        }
    }
}

func XCTAssertPathsEqual(_ path: [CodingKey], _ other: [DecodingKey]) {
    let convertedPath = path.map { DecodingKey(key: $0) }
    XCTAssertEqual(convertedPath, other)
}

func XCTAssertPathsEqual(_ path: [CodingKey], _ other: [Int]) {
    let convertedPath: [Int] = path.compactMap {
        guard let int = $0.intValue else {
            XCTFail("Found coding key '\($0.stringValue)' without integer value")
            return nil
        }
        return int
    }
    XCTAssertEqual(convertedPath, other)
}
