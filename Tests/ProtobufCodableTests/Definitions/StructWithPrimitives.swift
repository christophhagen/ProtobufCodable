import Foundation
import ProtobufCodable

struct StructWithPrimitives: Codable, Equatable {

    var double: Double = .zero
    var float: Float = .zero
    var int32: Int32 = .zero
    var int64: Int64 = .zero
    var uint32: UInt32 = .zero
    var uint64: UInt64 = .zero
    @Signed var sint32: Int32 = .zero
    @Signed var sint64: Int64 = .zero
    @Fixed var fixed32: UInt32 = .zero
    @Fixed var fixed64: UInt64 = .zero
    @Fixed var sfixed32: Int32 = .zero
    @Fixed var sfixed64: Int64 = .zero
    var bool: Bool = false
    var string: String = ""
    var bytes: Data = Data()

    enum CodingKeys: Int, CodingKey {
        case double = 1
        case float = 2
        case int32 = 3
        case int64 = 4
        case uint32 = 5
        case uint64 = 6
        case sint32 = 7
        case sint64 = 8
        case fixed32 = 9
        case fixed64 = 10
        case sfixed32 = 11
        case sfixed64 = 12
        case bool = 13
        case string = 14
        case bytes = 15
    }

    var proto: MessageWithPrimitives {
        .with {
            $0.double = double
            $0.float = float
            $0.int32 = int32
            $0.int64 = int64
            $0.uint32 = uint32
            $0.uint64 = uint64
            $0.sint32 = sint32
            $0.sint64 = sint64
            $0.fixed32 = fixed32
            $0.fixed64 = fixed64
            $0.sfixed32 = sfixed32
            $0.sfixed64 = sfixed64
            $0.bool = bool
            $0.string = string
            $0.bytes = bytes
        }
    }
}
