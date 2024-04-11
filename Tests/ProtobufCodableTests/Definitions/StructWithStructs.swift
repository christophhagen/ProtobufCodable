import Foundation
import ProtobufCodable

struct StructWithStructs: Codable, Equatable {

    let one: StructWithPrimitives

    let two: StructWithPrimitives?

    enum CodingKeys: Int, CodingKey {
        case one = 1
        case two = 2
    }
}

extension StructWithStructs: ProtoComparable {

    var proto: MessageWithMessages {
        .with {
            // If we set a struct it will be encoded as an empty container, even
            // if it contains the default value
            // Protobuf treats nested structs like optionals
            $0.one = one.proto
            if let two {
                $0.two = two.proto
            }
        }
    }
}
