import Foundation

/**
 A type that can be encoded and decoded as a variable-length integer
 */
typealias VariableLengthCodable = VariableLengthEncodable & VariableLengthDecodable

/**
 A type that can be encoded as a variable-length integer
 */
protocol VariableLengthEncodable: FixedWidthInteger {

    /// The value encoded as binary data using variable-length integer encoding
    var variableLengthEncoded: Data { get }
}

/**
 A type that can be decoded as a variable-length integer
 */
protocol VariableLengthDecodable: FixedWidthInteger {

    /**
     Decode a value as a variable-length integer.
     - Parameter data: The encoded value
     - Throws: ``CorruptedDataError``
     */
    init(fromVarint data: Data) throws
}
