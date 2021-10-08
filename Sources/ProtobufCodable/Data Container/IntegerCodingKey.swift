import Foundation

struct IntegerCodingKey {

    /**
     The amount by which an integer field is shifted to produce a nil key.

     The shift is `65535` (`Int16.max`)
     - Warning: Encoding/decoding breaks when fields within a single object exist with a difference exactly equal to the integer shift value.
     */
    static let shiftForNilKey = Int(Int16.max)

    /**
     Convert a coding key into a different key to encode data about nil values.
     - Parameter intValue: The integer value of the key to convert.
     */
    init(asNilKey intValue: Int) {
        self.intValue = intValue &+ IntegerCodingKey.shiftForNilKey
    }

    /**
     The integer value of the coding key.

     This value is never `nil`.
     Specified as an `Optional` to maintain conformance with the `CodingKey` protocol.
     */
    let intValue: Int?

    /**
     Create a key from an integer without any conversion of the value.
     - Parameter intValue: The integer value of the field
     */
    init(_ intValue: Int) {
        self.intValue = intValue
    }
}

extension IntegerCodingKey: CodingKey {

    /**
     Create an integer coding key from an integer.

     This constructor never returns `nil`.
    - Parameter intValue: The integer value of the key.
     */
    init?(intValue: Int) {
        self.intValue = intValue
    }

    /**
     This constructor always returns `nil`.
     */
    init?(stringValue: String) {
        return nil
    }

    /// The string representation of the integer key
    var stringValue: String {
        "\(intValue!)"
    }
}
