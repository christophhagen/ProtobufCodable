import Foundation

enum NilCodingKey: CodingKey {

    static let integerShift = Int(Int16.max)

    static let stringPrefix = "NIL"

    case intValue(Int)
    
    case stringValue(String)

    // MARK: CodingKey

    init(codingKey: CodingKey) {
        if let intValue = codingKey.intValue {
            let shifted = intValue &+ NilCodingKey.integerShift
            self = .intValue(shifted)
        } else {
            self = .stringValue(NilCodingKey.stringPrefix + codingKey.stringValue)
        }
    }

    init?(stringValue: String) {
        self = .stringValue(stringValue)
    }

    init?(intValue: Int) {
        self = .intValue(intValue)
    }

    var intValue: Int? {
        if case let .intValue(int) = self {
            return int
        }
        return nil
    }

    var stringValue: String {
        switch self {
        case .intValue(let value):
            return "\(value)"
        case .stringValue(let value):
            return value
        }
    }
}
