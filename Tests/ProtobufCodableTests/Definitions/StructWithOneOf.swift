import Foundation
import ProtobufCodable

struct StructWithOneOf: Codable, Equatable {

    var value: Int32 = .zero

    var oneOf: MyOneOf

    enum CodingKeys: Int, CodingKey {
        case value = 1
        case oneOf = 1234 // Not relevant, unused
    }
}

extension StructWithOneOf {

    enum MyOneOf: OneOf, Equatable {
        case string(String)
        case bytes(Data)
        case integer(Int32)
        case message(StructWithPrimitives)

        enum CodingKeys: Int, CodingKey {
            case string = 2
            case bytes = 3
            case integer = 4
            case message = 5
        }
    }
}

extension StructWithOneOf: ProtoComparable {

    var proto: MessageWithOneOf {
        .with {
            $0.value = value
            switch oneOf {
            case .string(let string):
                $0.string = string
            case .bytes(let bytes):
                $0.bytes = bytes
            case .integer(let integer):
                $0.int32 = integer
            case .message(let message):
                $0.message = message.proto
            }
        }
    }
}
