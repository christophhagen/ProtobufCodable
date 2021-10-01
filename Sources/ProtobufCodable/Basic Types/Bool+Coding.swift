import Foundation

extension Bool: BinaryEncodable {
    
    /**
     Encode the value to binary data compatible with the protobuf encoding.
     
     Encodes the value as a single byte of either `1` for  `true` or `0`for `false`
     */
    func binaryData() throws -> Data {
        .init([self ? 1 : 0])
    }
}

extension Bool: WireTypeProvider {

    /**
     The wire type of booleans.

     To conform the protobuf specification, booleans have wire type `varint`, but they are always encoded as a single byte.
     */
    public static var wireType: WireType {
        .varint
    }
}

extension Bool: BinaryDecodable {

    /**
     Create a boolean from a data container.

     A boolean occupies exactly one byte. If the byte is `zero`, then the boolean is set to `false`, otherwise `true`
     - Parameter byteProvider: The container with the encoded data.
     - Throws: `ProtobufDecodingError.missingData`, if no more bytes are available.
     */
    init(from byteProvider: DecodingDataProvider) throws {
        self = try byteProvider.getNextByte() > 0
    }

    /// The default protobuf value `false`
    static var defaultValue: Bool {
        false
    }
}
