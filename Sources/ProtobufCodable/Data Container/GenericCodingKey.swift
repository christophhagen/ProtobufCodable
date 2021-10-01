import Foundation

/**
 A coding key with either a string or an integer value.

 It is used to encode data about optionals within a keyed container, or to represent an unknown coding key.

 ## Nil coding keys

 Coding keys can be converted to a corresponding key in order to encode data about optionals.

 This concept is used to maintain compatibility with the Protobuf specification. The Codable implementation doesn't provide information about the existence of optionals within containers, so information about possible nil values must be encoded somewhere.
 */
enum GenericCodingKey: CodingKey {

    /**
     The nil key corresponds to an integer, which is shifted by a fixed value.
     - SeeAlso: `NilCodingKey.integerShift` for the used shifting value.
     */
    case intValue(Int)

    /**
     The nil key corresponds to a string, which is prepended by a prefix.
     - SeeAlso: `NilCodingKey.stringPrefix` for the used prefix
     */
    case stringValue(String)

    // MARK: Nil key operation constants

    /**
     The amount by which an integer field is shifted to produce a nil key.

     The shift is `65535` (`Int16.max`)
     - Warning: Encoding/decoding breaks when fields within a single object exist with a difference exactly equal to the integer shift value.
     */
    static let integerShift = Int(Int16.max)

    /**
     The prefix prepended to a string field to produce a nil key.

     The prefix is `NIL`.
     - Warning: Encoding/decoding breaks when an object contains a string key `"X"` as well as a string key `"NIL" + "X"`
     */
    static let stringPrefix = "NIL"

    /**
     Convert a coding key into a different key to encode data about nil values.
     - Parameter key: The key to convert.
     */
    init(convertingToNilKey key: CodingKey) {
        if let intValue = key.intValue {
            let shifted = intValue &+ GenericCodingKey.integerShift
            self = .intValue(shifted)
        } else {
            self = .stringValue(GenericCodingKey.stringPrefix + key.stringValue)
        }
    }

    /**
     Create a key from an integer without any conversion of the value.
     - Parameter value: The integer value of the field
     */
    init(_ value: Int) {
        self = .intValue(value)
    }

    /**
     Create a key from a string without any conversion of the value.
     - Parameter value: The string value of the field
     */
    init(_ value: String) {
        self = .stringValue(value)
    }

    // MARK: CodingKey

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
