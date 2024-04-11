import Foundation

/**
 A class acting as a decoder, to provide different containers for decoding.
 */
final class OneOfDecoder: AbstractDecodingNode, Decoder {

    private let elements: [Int: [DataField]]

    private var didCallContainer = false

    init(elements: [Int: [DataField]], codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.elements = elements
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard !didCallContainer else {
            throw DecodingError.corrupted("Multiple containers requested from decoder", codingPath: codingPath)
        }
        didCallContainer = true
        let container = OneOfKeyedDecoder<Key>(elements: elements, codingPath: codingPath, userInfo: userInfo)
        return .init(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.notSupported("OneOf doesn't support unkeyedContainer()", codingPath: codingPath)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.notSupported("OneOf doesn't support singleValueContainer()", codingPath: codingPath)
    }
}

private final class OneOfKeyedDecoder<Key: CodingKey>: AbstractDecodingNode, KeyedDecodingContainerProtocol {
    private let elements: [Int: [DataField]]

    init(elements: [Int: [DataField]], codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.elements = elements
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    var allKeys: [Key] {
        elements.keys.compactMap { .init(intValue: $0) }
    }

    func contains(_ key: Key) -> Bool {
        true
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        throw DecodingError.notSupported("OneOf doesn't support decodeNil(forKey:)", codingPath: codingPath + [key])
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard let integerKey = key.intValue else {
            throw DecodingError.notSupported("Missing integer value for key '\(key.stringValue)'", codingPath: codingPath + [key])
        }
        let data = elements[integerKey]
        let container = OneOfNestedKeyedDecoder<NestedKey>(data: data, codingPath: codingPath + [key], userInfo: userInfo)
        return .init(container)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DecodingError.notSupported("OneOf doesn't support nestedUnkeyedContainer(forKey:)", codingPath: codingPath + [key])
    }

    func superDecoder() throws -> Decoder {
        throw DecodingError.notSupported("OneOf doesn't support superDecoder()", codingPath: codingPath)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DecodingError.notSupported("OneOf doesn't support superDecoder(forKey:)", codingPath: codingPath + [key])
    }
}

private final class OneOfNestedKeyedDecoder<Key: CodingKey>: AbstractDecodingNode, KeyedDecodingContainerProtocol {

    private let data: [DataField]?

    init(data: [DataField]?, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    var allKeys: [Key] {
        [.init(stringValue: "_0")!]
    }

    func contains(_ key: Key) -> Bool {
        true
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        throw DecodingError.notSupported("OneOf doesn't support decodeNil(forKey:)", codingPath: codingPath + [key])
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.notSupported("OneOf doesn't support nestedContainer<NestedKey>(keyedBy:forKey:)", codingPath: codingPath + [key])
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        guard key.stringValue == "_0" else {
            throw DecodingError.notSupported("Unexpected OneOf associated value key '\(key.stringValue)'", codingPath: codingPath + [key])
        }
        if let BaseType = T.self as? DecodablePrimitive.Type {
            return try wrapCorruptDataError(at: codingPath) {
                try BaseType.init(elements: data) as! T
            }
        }
        let node = DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
        return try type.init(from: node)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DecodingError.notSupported("OneOf doesn't support nestedUnkeyedContainer(forKey:)", codingPath: codingPath + [key])
    }

    func superDecoder() throws -> Decoder {
        throw DecodingError.notSupported("OneOf doesn't support superDecoder()", codingPath: codingPath)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DecodingError.notSupported("OneOf doesn't support superDecoder(forKey:)", codingPath: codingPath + [key])
    }
}
