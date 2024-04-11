import Foundation

struct StructWithEnum: Codable, Equatable {

    enum Enum: Int, Codable {
        case zero = 0
        case one = 1
    }

    let value: Enum

    enum CodingKeys: Int, CodingKey {
        case value = 1
    }
}

extension StructWithEnum: ProtoComparable {

    var proto: MessageWithEnum {
        .with {
            $0.value = .init(rawValue: value.rawValue)!
        }
    }
}
