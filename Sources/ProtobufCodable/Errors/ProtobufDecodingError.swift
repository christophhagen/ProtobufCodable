import Foundation

/**
 A collection of errors which can occur when decoding instances with a ``ProtobufDecoder``
 */
public enum ProtobufDecodingError: Error {

    /// The decoder reached the end of the data without decoding the complete instance.
    case missingData

    /// An variable-length integer (within a key or as a value) was not encoded properly and could not be decoded.
    case invalidVarintEncoding

    /// An integer was encoded using variable-length encoding but did not fit inside the specified type.
    case variableLengthEncodedValueOutOfRange

    /// A string key or value could not be decoded using UTF-8.
    case invalidString

    /// The decoder expected a field with value `1` while decoding a dictionary key
    case missingDictionaryKey

    /// The decoder expected a field with value `2` while decoding a dictionary value
    case missingDictionaryValue

    /// The decoder expected a field with value `1` or `2` while decoding a dictionary key pair
    case invalidDictionaryKey

    /**
     The decoded type requested a feature of the decoder which is currently unimplemented.

     The associated string contains a description of the unimplemented feature.
     */
    case notImplemented(String)
}
