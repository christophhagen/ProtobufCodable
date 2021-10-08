import Foundation

final class KeyedEncoder<Key>: ObjectEncoder, KeyedEncodingContainerProtocol where Key: CodingKey {

    // MARK: Encoding

    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.notImplemented("KeyedEncodingContainer.encodeNil(forKey:)")
    }

    /**
     Encodes the given value for the given key.
     - Parameter value: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            if primitive.isDefaultValue && omitDefaultValues { return }
            try addObject {
                try primitive.encoded(withKey: key, requireIntegerKey: requireIntegerCodingKeys)
            }
        case is AnyDictionary:
            try encodeDictionary(value, forKey: key)
        default:
            try encodeChild(value, forKey: key)
        }
    }

    /**
     Encodes the given dictionary for the given key.

     A dictionary is encoded as a set of key-value pairs, which are encoded within a container using field ids 1 (key) and 2 (value).
     - Parameter dictionary: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeDictionary(_ dictionary: Encodable, forKey key: CodingKey) throws {
        let encoder = addObject {
            DictionaryEncoder(path: [], key: key, info: userInfo)
        }
        try dictionary.encode(to: encoder)
    }

    /**
     Encodes a complex object for the given key.

     - Parameter child: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeChild(_ child: Encodable, forKey key: CodingKey) throws {
        let encoder = addObject {
            TopLevelEncoder(path: codingPath + [key], key: key, info: userInfo)
        }
        try child.encode(to: encoder)
    }

    // MARK: Nesting

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = addObject {
            KeyedEncoder<NestedKey>(path: codingPath + [key], key: key, info: userInfo)
        }
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        addObject {
            UnkeyedEncoder(path: codingPath + [key], key: key, info: userInfo)
        }
    }

    func superEncoder() -> Encoder {
        addObject {
            TopLevelEncoder(path: codingPath, key: key, info: userInfo)
        }
    }

    func superEncoder(forKey key: Key) -> Encoder {
        addObject {
            TopLevelEncoder(path: codingPath + [key], key: key, info: userInfo)
        }
    }
}

// MARK: EncodedDataProvider

extension KeyedEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        let data = try objects.reduce(.empty) { try $0 + $1.encodedData() }
        if let key = self.key {
            return try data.encoded(withKey: key, requireIntegerKey: requireIntegerCodingKeys)
        }
        return data
    }
}
