import Foundation

/**
 A protocol adopted by all types which can be converted to binary data.
 */
 protocol BinaryEncodable: WireTypeProvider, Encodable {
    
    /**
     Encode the value to binary data compatible with the protobuf encoding.
     
     - Throws: `ProtobufEncodingError` errors if the encoding can't be performed.
     - Returns: The binary data of the encoded value.
     */
    func binaryData() throws -> Data
    
    /**
     The value is equal to the default value for the type.
     */
    var isDefaultValue: Bool { get }
}

extension BinaryEncodable where Self: BinaryDecodable, Self: Equatable {

    /// The value is equal to the default protobuf value `false`
    var isDefaultValue: Bool {
        self == Self.defaultValue
    }
}

extension BinaryEncodable {

    /**
     Encodes a value with a key by prepending a tag.

     - Note: Values requiring length information (e.g `String`, `Data`) have the length information added after the tag.
     - Parameter key: The coding key to use for encoding.
     - Returns: The encoded data, with a tag and the length information prepended (if needed)
     */
    func encoded(withKey key: CodingKey) throws -> Data {
        try Tag(type: wireType, key: key).data() + encodedWithLengthIfNeeded()
    }

    /**
     Encode a value without a key, and including length information for appropriate types.
     - Returns: The encoded data, with the length information prepended (if needed)
     */
    func encodedWithLengthIfNeeded() throws -> Data {
        let data = try binaryData()
        guard wireType == .lengthDelimited else {
            return data
        }
        return data.count.binaryData() + data
    }
}
