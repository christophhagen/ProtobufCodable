import Foundation

extension Data: BinaryEncodable {
    
    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data without change.
     */
    func binaryData() throws -> Data {
        self
    }
}

extension Data: WireTypeProvider {
    
    /// The wire type of binary data (length delimited)
    public static var wireType: WireType {
        .lengthDelimited
    }
}

extension Data: BinaryDecodable {

    /**
     Create data from a data container.

     The data uses all remaining bytes from the container.
     - Parameter byteProvider: The container with the encoded data.
     */
    init(from byteProvider: DecodingDataProvider) {
        self = byteProvider.getRemainingBytes()
    }

    /// An empty data object is the default.
    static var defaultValue: Data {
        .empty
    }
}
