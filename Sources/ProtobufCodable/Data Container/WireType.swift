import Foundation

/**
 A wire type provides just enough information to find the length of the following value.
 
 - Note: All wire types are defined in the [Protocol Buffer Message Structure](https://developers.google.com/protocol-buffers/docs/encoding#structure) definition.
 */
public enum WireType: Int {
    
    /**
     Variable-length value.
     
     Used for: `int32`, `int64`, `uint32`, `uint64`, `sint32`, `sint64`, `bool`, `enum`
     */
    case varint = 0
    
    /**
     Fixed-length value of eight bytes.
     
     Used for: `fixed64`, `sfixed64`, `double`
     */
    case length64 = 1
    
    /**
     A value defined by a variable-length integer followed by the corresponding number of elements.
     
     Used for: `string`, `bytes`, embedded messages, packed repeated fields
     */
    case lengthDelimited = 2

    /**
     Start group.
     
     Used for: groups (deprecated).
     */
    //@available(*, deprecated, message: "Deprecated wire type")
    //case startGroup = 3
    
    /**
     End group.
     
     Used for: groups (deprecated)
     */
    //@available(*, deprecated, message: "Deprecated wire type")
    //case endGroup = 4
    
    /**
     Indicates the presence of a string key.

     A string key is composed of the string length as the field number, followed by the actual field name as a UTF-8 string.
     A second tag (field nr = 0) follows the string, describing the actual data contained in the field.
     */
    case stringKey = 3

    /**
     Encodes a nil value.
     
     - Note: Abuses the deprecated `endGroup` wire type value `4`
     - Warning: Incompatible with the official protocol buffer definition.
     */
    case nilValue = 4
    
    /**
     Fixed-length value of four bytes.
     
     Used for: `fixed32`, `sfixed32`, `float`
     */
    case length32 = 5
    
    /**
     Fixed-length value of one byte.
     
     - Warning: Incompatible with the official protocol buffer definition.
     */
    case length8 = 6
    
    /**
     Fixed-length value of two bytes.
     
     - Warning: Incompatible with the official protocol buffer definition.
     */
    case length16 = 7
}

extension WireType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .varint:
            return "varint"
        case .length64:
            return "64bit"
        case .lengthDelimited:
            return "length"
            // case .startGroup:
            //    return "startGroup"
            // case .endGroup:
            //     return "endGroup"
        case .stringKey:
            return "string key"
        case .nilValue:
            return "nil"
        case .length32:
            return "32bit"
        case .length8:
            return "8bit"
        case .length16:
            return "16bit"
        }
    }
}

extension WireType: Decodable {
    
    /// Indicate if the wire type is compatible with the Google Protobuf definition.
    var isProtobufCompatible: Bool {
        switch self {
        case .nilValue, .length8, .length16:
            return false
        default:
            return true
        }
    }
}
