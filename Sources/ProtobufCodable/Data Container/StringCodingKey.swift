import Foundation

struct StringCodingKey: CodingKey {

    /**
     The prefix prepended to a string field to produce a nil key.

     The prefix is `NIL`.
     - Warning: Encoding/decoding breaks when an object contains a string key `"X"` as well as a string key `"NIL" + "X"`
     */
    static let prefixForNilKey = "NIL"

    /**
     Convert a coding key into a different key to encode data about nil values.
     - Parameter stringValue: The string value of the key to convert.
     */
    init(asNilKey stringValue: String) {
        self.stringValue = StringCodingKey.prefixForNilKey + stringValue
    }

    /**
     Create a key from a string without any conversion of the value.
     - Parameter stringValue: The string value of the field
     */
    init(_ stringValue: String) {
        self.stringValue = stringValue
    }

    /**
     This contructor always returns `nil`
     */
    init?(intValue: Int) {
        return nil
    }

    /**
     This contructor never returns `nil`.
     - Parameter stringValue: The string of the key.
     */
    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    /// A string key has no integer value
    var intValue: Int? {
        nil
    }

    /// The string value of the key
    let stringValue: String
}
