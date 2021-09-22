import Foundation

extension Bool: BinaryEncodable {
    
    /**
     Encode the value to binary data compatible with the protobuf encoding.
     
     Encodes the value as a single byte of either `1` for  `true` or `0`for `false`
     */
    public func binaryData() throws -> Data {
        .init([self ? 1 : 0])
    }
    
    /// The wire type of booleans.
    public static var wireType: WireType {
        .varint
    }
}

extension Bool: BinaryDecodable {
    
    public init(from byteProvider: DecodingDataProvider) throws {
        self = try byteProvider.getNextByte() > 0
    }

    /// The default protobuf value `false`
    public static var defaultValue: Bool {
        false
    }
}
