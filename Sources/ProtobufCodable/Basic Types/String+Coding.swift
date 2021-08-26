import Foundation

extension String: BinaryEncodable {
    
    /**
     Encodes a string using the UTF8 representation.
     
     - Note: The length of the string is prepended to the data encoded as a variable-length unsigned integer.
     - Throws: `BinaryEncodingError.stringNotRepresentableInUTF8` if the string can't be converted to UTF8
     */
    public func binaryData() throws -> Data {
        guard let data = data(using: .utf8) else {
            throw ProtobufEncodingError.stringNotRepresentableInUTF8(self)
        }
        return data
    }
    
    /// The wire type of a string (`lengthDelimited`)
    public var wireType: WireType {
        .lengthDelimited
    }
}
