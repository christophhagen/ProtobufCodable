import Foundation

/**
 A protocol adopted by all types which can be converted to binary data.
 */
public protocol BinaryEncodable: WireTypeProvider, Encodable {
    
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
    public var isDefaultValue: Bool {
        self == Self.defaultValue
    }
}

extension BinaryEncodable {

    func binaryDataIncludingLengthIfNeeded() throws -> Data {
        let data = try binaryData()
        if wireType == .lengthDelimited {
            return data.count.variableLengthEncoding + data
        }
        return data
    }
}
