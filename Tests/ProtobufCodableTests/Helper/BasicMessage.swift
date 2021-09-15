import Foundation
import ProtobufCodable

struct BasicMessage: Codable {
    
    enum CodingKeys: Int, CodingKey {
        case double = 1
        case float = 2
        case int32 = 3
        case int64 = 4
        case unsignedInt32 = 5
        case unsignedInt64 = 6
        case signedInt32 = 7
        case signedInt64 = 8
        case fixedInt32 = 9
        case fixedInt64 = 10
        case signedFixedInt32 = 11
        case signedFixedInt64 = 12
        case boolean = 13
        case string = 14
        case bytes = 15
    }
    
    var double: Double = 0
    
    var float: Float = 0
    
    var int32: Int32 = 0
    
    var int64: Int64 = 0
    
    var unsignedInt32: UInt32 = 0
    
    var unsignedInt64: UInt64 = 0
    
    @SignedValue
    var signedInt32: Int32 = 0
    
    @SignedValue
    var signedInt64: Int64 = 0
    
    @FixedLength
    var fixedInt32: UInt32 = 0
    
    @FixedLength
    var fixedInt64: UInt64 = 0
    
    @FixedLength
    var signedFixedInt32: Int32 = 0
    
    @FixedLength
    var signedFixedInt64: Int64 = 0
    
    var boolean: Bool = false
    
    var string: String = .empty
    
    var bytes: Data = .empty
}

extension BasicMessage: ProtobufComparable {

    var protobuf: PB_BasicMessage {
        .with {
            $0.double = double
            $0.float = float
            $0.int32 = int32
            $0.int64 = int64
            $0.unsignedInt32 = unsignedInt32
            $0.unsignedInt64 = unsignedInt64
            $0.signedInt32 = signedInt32
            $0.signedInt64 = signedInt64
            $0.fixedInt32 = fixedInt32
            $0.fixedInt64 = fixedInt64
            $0.signedFixedInt32 = signedFixedInt32
            $0.signedFixedInt64 = signedFixedInt64
            $0.boolean = boolean
            $0.string = string
            $0.bytes = bytes
        }
    }
}
