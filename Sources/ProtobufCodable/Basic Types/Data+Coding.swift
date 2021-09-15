import Foundation

extension Data: BinaryEncodable {
    
    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data without change.
     */
    public func binaryData() throws -> Data {
        self
    }
    
    /// The wire type of binary data (length delimited)
    public var wireType: WireType {
        .lengthDelimited
    }
}

extension Data: BinaryDecodable {
    
    public init(from byteProvider: DecodingDataProvider) throws {
        #warning("Should we encode/decode the length for Data?")
        self = byteProvider.getRemainingBytes()
    }
}
