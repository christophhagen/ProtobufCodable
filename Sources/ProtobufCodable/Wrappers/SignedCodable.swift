import Foundation

/**
 A type that can be encoded and decoded as a variable-length integer using zig-zag encoding.
 
 Positive integers `p` are encoded as `2 * p` (the even numbers), while negative integers `n` are encoded as `2 * |n| - 1` (the odd numbers).
 The encoding thus "zig-zags" between positive and negative numbers.
 - SeeAlso: [Protobuf signed integers](https://developers.google.com/protocol-buffers/docs/encoding#signed-ints)
 */
public typealias SignedCodable = SignedEncodable & SignedDecodable

/**
 A type that can be encoded as a zig-zag variable-length integer
 */
public protocol SignedEncodable {
    
    /// The protobuf type equivalent to the signed size type
    var signedProtoTypeName: String { get }

    /// The value encoded as binary data using zig-zag variable-length integer encoding
    var signedEncoded: Data { get }

}

/**
 A type that can be decoded as a zig-zag variable-length integer
 */
public protocol SignedDecodable {

    /**
     Decode a value as a zig-zag variable-length integer.
     - Parameter data: The encoded value
     - Throws: ``CorruptedDataError``
     */
    init(fromSigned data: Data) throws
}

