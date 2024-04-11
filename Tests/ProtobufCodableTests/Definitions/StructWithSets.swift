import Foundation
import ProtobufCodable

struct StructWithSets: Codable, Equatable {

    var double: Set<Double> = []
    var float: Set<Float> = []
    var int32: Set<Int32> = []
    var int64: Set<Int64> = []
    var uint32: Set<UInt32> = []
    var uint64: Set<UInt64> = []
    var sint32: Set<Signed<Int32>> = []
    var sint64: Set<Signed<Int64>> = []
    var fixed32: Set<Fixed<UInt32>> = []
    var fixed64: Set<Fixed<UInt64>> = []
    var sfixed32: Set<Fixed<Int32>> = []
    var sfixed64: Set<Fixed<Int64>> = []
    var bool: Set<Bool> = []
    var string: Set<String> = []
    var bytes: Set<Data> = []

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
}

extension StructWithSets: ProtoComparable {

    var proto: MessageWithArrays {
        .with {
            $0.double = double.map { $0 }
            $0.float = float.map { $0 }
            $0.int32 = int32.map { $0 }
            $0.int64 = int64.map { $0 }
            $0.uint32 = uint32.map { $0 }
            $0.uint64 = uint64.map { $0 }
            $0.sint32 = sint32.map { $0.wrappedValue }
            $0.sint64 = sint64.map { $0.wrappedValue }
            $0.fixed32 = fixed32.map { $0.wrappedValue }
            $0.fixed64 = fixed64.map { $0.wrappedValue }
            $0.sfixed32 = sfixed32.map { $0.wrappedValue }
            $0.sfixed64 = sfixed64.map { $0.wrappedValue }
            $0.bool = bool.map { $0 }
            $0.string = string.map { $0 }
            $0.bytes = bytes.map { $0 }
        }
    }
}
