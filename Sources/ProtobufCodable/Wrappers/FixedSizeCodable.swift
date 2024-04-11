import Foundation

/**
 A type that can be encoded and decoded as a fixed-size value.
 */
public typealias FixedSizeCodable = FixedSizeEncodable & FixedSizeDecodable

/// An integer type which can be forced to use a fixed-length encoding instead of variable-length encoding.
public protocol FixedSizeEncodable: Encodable {

    /// The wire type of the type, which has a constant length
    static var fixedDataType: WireType { get }

    /// The protobuf type equivalent to the fixed size type
    var fixedProtoTypeName: String { get }

    /// The value encoded as fixed size binary data
    var fixedSizeEncoded: Data { get }
}

extension FixedSizeEncodable {

    /// The wire type of the value, which has a constant length
    var fixedDataType: WireType {
        Self.fixedDataType
    }
}


/**
 A type that can be encoded with a fixed number of bytes.
 */
public protocol FixedSizeDecodable: Decodable {

    /**
     Decode the value from binary data.
     - Parameter data: The binary data of the correct size for the type.
     - Throws: ``CorruptedDataError``
     */
    init(fromFixedSize data: Data) throws
}
