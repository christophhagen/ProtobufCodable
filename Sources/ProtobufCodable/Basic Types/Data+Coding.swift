import Foundation

extension Data: BinaryEncodable {
    
    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data without change.
     */
    public func binaryData() throws -> Data {
        self
//        count.variableLengthEncoding + self
    }
    
    /// The wire type of binary data (length delimited)
    public static var wireType: WireType {
        .lengthDelimited
    }
}

extension Data: BinaryDecodable {
    
    public init(from byteProvider: DecodingDataProvider) throws {
        self = byteProvider.getRemainingBytes()
//        let count = try Int(from: byteProvider)
//        self = try byteProvider.getNextBytes(count)
    }

    public static var defaultValue: Data {
        .empty
    }
}
