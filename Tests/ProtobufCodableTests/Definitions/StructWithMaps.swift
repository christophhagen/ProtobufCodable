import Foundation

struct StructWithMaps: Codable, Equatable {

    var stringToBytes: [String: Data] = [:]

    var uintToString: [UInt32: String] = [:]

    var intToMessage: [Int: StructWithPrimitives] = [:]

    enum CodingKeys: Int, CodingKey {
        case stringToBytes = 1
        case uintToString = 2
        case intToMessage = 3
    }
}

extension StructWithMaps: ProtoComparable {

    var proto: MessageWithMaps {
        .with {
            $0.stringToBytes = stringToBytes
            $0.uintToString = uintToString
            $0.intToMessage = intToMessage
                .reduce(into: [:]) {
                    $0[Int64($1.key)] = $1.value.proto
                }
        }
    }
}
