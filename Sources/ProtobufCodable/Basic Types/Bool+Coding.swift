import Foundation

extension Bool: BinaryPrimitiveEncodable {
    
    /**
     Encode the value to binary data compatible with the protobuf encoding.
     
     Encodes the value as a single byte of either `1` for  `true` or an empty data object for `false`
     */
    public func binaryData() throws -> Data {
        UInt64(self ? 1 : 0).variableLengthEncoding
    }
    
    public var isDefaultValue: Bool { !self }
    
    public var wireType: WireType {
        .varint
    }
}
