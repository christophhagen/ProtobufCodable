import Foundation

/**
 A collection of errors which can occur when encoding objects using a ``ProtobufEncoder``.
 */
public enum ProtobufEncodingError: Error {

    /**
     A type did not specify integer coding keys.

     The associated value is the `CodingKey` violating the integer requirement.

     - Note: This error can only occur when the `requireIntegerCodingKeys` property of the ``ProtobufEncoder`` is set to `true`.
     */
    case missingIntegerCodingKey(CodingKey)

    /**
     The encoded type requested a feature of the encoder which is currently unimplemented.

     The associated string contains a description of the unimplemented feature.
     */
    case notImplemented(String)
    
    /**
     A string value can't be represented using UTF-8 encoding.

     The associated string contains the invalid string.
     */
    case stringNotRepresentableInUTF8(_ failingString: String)
}
