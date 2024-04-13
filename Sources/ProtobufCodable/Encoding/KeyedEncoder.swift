import Foundation

final class KeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var encodedValues: [(key: Int, value: EncodableContainer)] = []

    private func contains(_ key: Int) -> Bool {
        encodedValues.contains { $0.key == key }
    }

    private func add(_ value: EncodableContainer, forKey key: Int) {
        encodedValues.append((key, value))
    }

    private func validIntegerKey<T>(for key: CodingKey, value: T) throws -> Int {
        guard let integerKey = key.intValue else {
            throw EncodingError.unsupported(key, "Missing integer key for '\(key.stringValue)'", codingPath: codingPath + [key])
        }
        guard integerKey.isValidProtobufFieldNumber else {
            throw EncodingError.unsupported(key, "Invalid integer key \(integerKey) for '\(key.stringValue)'", codingPath: codingPath + [key])
        }
        guard !contains(integerKey) else {
            throw EncodingError.invalidValue(value, .init(codingPath: codingPath + [key], debugDescription: "Multiple values assigned to key \(key)"))
        }
        return integerKey
    }

    func encodeNil(forKey key: Key) throws {
        // Do nothing, just don't encode the key
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if T.self is OneOf.Type {
            try encode(oneOf: value, forKey: key)
            return
        }

        let integerKey = try validIntegerKey(for: key, value: value)
        let element = try encode(value: value, forKey: key)
        add(element, forKey: integerKey)
    }

    private func encode<T>(value: T, forKey key: CodingKey) throws -> EncodableContainer where T: Encodable {
        if T.self is UnsupportedEncodable.Type { // Fail gracefully for unsupported primitive types
            throw EncodingError.unsupported(value, "Unsupported value of type \(T.self) for key '\(key.stringValue)'", codingPath: codingPath)
        } else if T.self is EncodablePrimitive.Type { // Test like this to prevent Optionals from being matched
            return value as! EncodablePrimitive // Then force cast since it will always succeed
        } else if T.self is EncodableContainer.Type { // Test like this to prevent Optionals from being matched
            return (value as! EncodableContainer) // Then force cast since it will always succeed
        } else if T.self is AnyDictionary.Type { // Unsupported dictionary, supported dicts are matched as EncodableContainer
            throw EncodingError.unsupported(value, "Unsupported dictionary type", codingPath: codingPath + [key])
        } else {
            return try encode(other: value, forKey: key)
        }
    }

    private func encode<T>(oneOf: T, forKey key: CodingKey) throws where T: Encodable {
        let encoder = OneOfEncoder(codingPath: codingPath + [key], userInfo: userInfo)
        try oneOf.encode(to: encoder)
        guard let key = encoder.encodedKey else {
            throw EncodingError.unsupported(oneOf, "No value encoded for OneOf", codingPath: codingPath)
        }
        let integerKey = try validIntegerKey(for: key, value: oneOf)
        add(encoder, forKey: integerKey)
    }

    private func encode<T>(other value: T, forKey key: CodingKey) throws -> EncodableContainer where T: Encodable {
        let node = EncodingNode(codingPath: codingPath + [key], userInfo: userInfo)
        try value.encode(to: node)
        return node
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        .init(UnsupportedKeyedEncoder("Nested keyed containers are not supported in keyed containers"))
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder("Nested unkeyed containers are not supported in keyed containers")
    }

    func superEncoder() -> Encoder {
        UnsupportedSuperEncoder("Encoding super in keyed containers is not supported")
    }

    func superEncoder(forKey key: Key) -> any Encoder {
        superEncoder()
    }
}

extension KeyedEncoder: EncodableContainer {

    func encode(forKey key: Int) throws -> Data {
        try encodeForUnkeyedContainer().encodeAlways(forKey: key)
    }

    func encodeForUnkeyedContainer() throws -> Data {
        guard sortKeysDuringEncoding else {
            return try encode(elements: encodedValues)
        }
        return try encode(elements: encodedValues.sorted { $0.key < $1.key })
    }

    private func encode<T>(elements: T) throws -> Data where T: Collection, T.Element == (key: Int, value: EncodableContainer) {
        try elements.mapAndJoin { key, value in
            try value.encode(forKey: key)
        }
    }
}
