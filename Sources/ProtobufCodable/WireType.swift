import Foundation

/**
 A wire type provides just enough information to find the length of the following value.
 */
public enum WireType: Int {
    
    /**
     Variable-length value.
     
     Used for: `int32`, `int64`, `uint32`, `uint64`, `sint32`, `sint64`, `bool`, `enum`
     */
    case varint = 0
    
    /**
     Fixed-length value of eight bytes
     
     Used for: `fixed64`, `sfixed64`, `double`
     */
    case length64 = 1
    
    /**
     A value defined by a variable-length integer followed by the corresponding number of elements.
     
     Used for: `string`, `bytes`, embedded messages, packed repeated fields
     */
    case lengthDelimited = 2
    
    /**
     Start group
     
     Used for: groups (deprecated).
     */
    case startGroup = 3
    
    /**
     End group
     
     Used for: groups (deprecated)
     */
    case endGroup = 4
    
    /**
     Fixed-length value of four bytes
     
     Used for: `fixed32`, `sfixed32`, `float`
     */
    case length32 = 5
    
    case length8 = 6
    
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
        case .startGroup:
            return "startGroup"
        case .endGroup:
            return "endGroup"
        case .length32:
            return "32bit"
        case .length8:
            return "8bit"
        case .length16:
            return "16bit"
        }
    }
}

extension WireType {
    
    func tag(with field: Int) -> Data {
        let typeAndTag = (field << 3) + rawValue
        return typeAndTag.binaryData()
    }
}
