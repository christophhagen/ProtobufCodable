import Foundation

final class KeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    let allKeys: [Key]

    private let elements: [Int: [DataField]]

    init(data: [DataField]?, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        guard let data = data?.last else {
            self.elements = [:]
            self.allKeys = []
            super.init(codingPath: codingPath, userInfo: userInfo)
            return
        }
        guard data.type == .len else {
            throw CorruptedDataError(invalidType: data.type, for: "keyed container").adding(codingPath: codingPath)
        }
        self.elements = try wrapCorruptDataError(at: codingPath) {
            try data.data.decodeKeyDataPairs()
        }

        self.allKeys = elements.keys.compactMap { Key(intValue: $0) }
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    private func value(for key: CodingKey) throws -> [DataField]? {
        guard let intKey = key.intValue else {
            throw DecodingError.notSupported("Missing integer key for key '\(key.stringValue)'", codingPath: codingPath + [key])
        }
        return elements[intKey]
    }

    private func node(for key: CodingKey) throws -> DecodingNode {
        let element = try value(for: key)
        return DecodingNode(data: element, codingPath: codingPath + [key], userInfo: userInfo)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedDecodingContainer(try node(for: key).container(keyedBy: type))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try node(for: key).unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        throw DecodingError.notSupported("Decoding super is not supported", codingPath: codingPath)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DecodingError.notSupported("Decoding super is not supported", codingPath: codingPath + [key])
    }

    func contains(_ key: Key) -> Bool {
        // Pretend that all keys are available, so that default values can be decoded
        true
    }

    func decodeNil(forKey key: Key) -> Bool {
        guard let integerKey = key.intValue else {
            // Force decoding of string keys, so that an error can be thrown
            return false
        }
        return !elements.contains(where: { $0.key == integerKey })
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let element = try value(for: key)
        if type is OneOf.Type {
            return try decodeOneOf(codingPath: codingPath + [key])
        }
        return try decode(elements: element, type: type, codingPath: codingPath + [key])
    }

    private func decodeOneOf<T>(codingPath: [CodingKey]) throws -> T where T: Decodable {
        // Create container with all available keys, since OneOf uses different coding keys
        let decoder = OneOfDecoder(elements: elements, codingPath: codingPath, userInfo: userInfo)
        return try T.init(from: decoder)
    }
}
