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

public extension BinaryEncodable where Self: AdditiveArithmetic {
    
    /**
     The value is equal to the default value for an integer (`zero`)
     */
    var isDefaultValue: Bool { self == .zero }
}

public extension BinaryEncodable where Self: Collection {
    
    /**
     The value is equal to the default value for a collection (`[]`)
     */
    var isDefaultValue: Bool { isEmpty }
}

