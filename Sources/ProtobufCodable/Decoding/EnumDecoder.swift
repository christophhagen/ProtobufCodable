import Foundation

final class EnumDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let elements: [DataField]?

    init(elements: [DataField]?, codingPath: [CodingKey], userInfo: UserInfo) {
        self.elements = elements
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func decodeNil() -> Bool {
        elements == nil
    }

    func decode(_ type: Int.Type) throws -> Int {
        try decode(elements: elements, type: type, codingPath: codingPath)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Invalid RawValue \(type) for enum"))
    }
}
