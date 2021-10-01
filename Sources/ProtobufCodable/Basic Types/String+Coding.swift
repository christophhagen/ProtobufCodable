import Foundation

extension String: BinaryEncodable {
    
    /**
     Encodes a string using the UTF8 representation.
     
     - Note: The length of the string is prepended to the data encoded as a variable-length unsigned integer.
     - Throws: `BinaryEncodingError.stringNotRepresentableInUTF8` if the string can't be converted to UTF8
     */
    func binaryData() throws -> Data {
        guard let data = data(using: .utf8) else {
            throw ProtobufEncodingError.stringNotRepresentableInUTF8(self)
        }
        return data
        // return data.count.variableLengthEncoding + data
    }
}

extension String: WireTypeProvider {
    
    /// The wire type of a string (`lengthDelimited`)
    public static var wireType: WireType {
        .lengthDelimited
    }
}

extension String: BinaryDecodable {

    /**
     Decode a string from a data provider.

     Reads all remaining bytes from the container.
     - Throws: `ProtobufDecodingError.invalidString`, if the string encoding is invalid.
     */
    init(from byteProvider: DecodingDataProvider) throws {
        let data = byteProvider.getRemainingBytes()
        guard let s = String(data: data, encoding: .utf8) else {
            throw ProtobufDecodingError.invalidString
        }
        self = s
    }

    /// The default value is an empty string.
    static var defaultValue: String {
        .empty
    }
}
