import Foundation

public protocol BinaryEncodable: WireTypeProvider, Codable {
    
    /**
     Encode the value to binary data compatible with the protobuf encoding.
     
     - Throws: `ProtobufEncodingError` errors if the encoding can't be performed.
     - Returns: The binary data of the encoded value.
     */
    func binaryData() throws -> Data

}

public protocol BinaryPrimitiveEncodable: BinaryEncodable {
    
    var isDefaultValue: Bool { get }
}

public extension BinaryPrimitiveEncodable where Self: AdditiveArithmetic {
    
    var isDefaultValue: Bool { self == .zero }
}

public extension BinaryPrimitiveEncodable where Self: Collection {
    
    var isDefaultValue: Bool { isEmpty }
}

