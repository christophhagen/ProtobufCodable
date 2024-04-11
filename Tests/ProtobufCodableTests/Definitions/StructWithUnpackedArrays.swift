import Foundation
import ProtobufCodable

struct StructWithUnpackedArrays: Codable, Equatable {

    @Unpacked
    var double: [Double] = []

    @Unpacked
    var float: [Float] = []

    @Unpacked
    var int32: [Int32] = []

    @Unpacked
    var int64: [Int64] = []

    @Unpacked
    var uint32: [UInt32] = []

    @Unpacked
    var uint64: [UInt64] = []

    @Unpacked
    var sint32: [Signed<Int32>] = []

    @Unpacked
    var sint64: [Signed<Int64>] = []

    @Unpacked
    var fixed32: [Fixed<UInt32>] = []

    @Unpacked
    var fixed64: [Fixed<UInt64>] = []

    @Unpacked
    var sfixed32: [Fixed<Int32>] = []

    @Unpacked
    var sfixed64: [Fixed<Int64>] = []

    @Unpacked
    var bool: [Bool] = []

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
    }

    var proto: MessageWithUnpackedArrays {
        .with {
            $0.double = double
            $0.float = float
            $0.int32 = int32
            $0.int64 = int64
            $0.uint32 = uint32
            $0.uint64 = uint64
            $0.sint32 = sint32.map { $0.wrappedValue }
            $0.sint64 = sint64.map { $0.wrappedValue }
            $0.fixed32 = fixed32.map { $0.wrappedValue }
            $0.fixed64 = fixed64.map { $0.wrappedValue }
            $0.sfixed32 = sfixed32.map { $0.wrappedValue }
            $0.sfixed64 = sfixed64.map { $0.wrappedValue }
            $0.bool = bool
        }
    }
}

