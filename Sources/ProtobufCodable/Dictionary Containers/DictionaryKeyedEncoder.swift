import Foundation

/**
 A dictionary encoding node for cases where the dictionary keys are either integers or strings.
 */
final class DictionaryKeyedEncoder<Key>: ObjectEncoder, KeyedEncodingContainerProtocol where Key: CodingKey {

    // MARK: Encoding

    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.notImplemented("Dictionary.KeyedEncodingContainer.encodeNil(forKey:)")
    }

    /**
     Encode a value for a dictionary key.
     */
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        // Here we encode the key (integer or string) and the value
        // It's a bit confusing that the Codable implementation uses CodingKeys
        // to encode dictionary keys when the types are `Int` or `String`
        if let int = key.intValue {
            try encode(value, integerKey: int)
        } else {
            try encode(value, stringKey: key.stringValue)
        }
    }

    private func encode<T>(_ value: T, integerKey: Int) throws where T : Encodable {
        let pair = KeyValuePair(key: integerKey, value: value)
        try encode(keyPair: pair)
    }

    private func encode<T>(_ value: T, stringKey: String) throws where T : Encodable {
        let pair = KeyValuePair(key: stringKey, value: value)
        try encode(keyPair: pair)
    }

    private func encode(keyPair: Encodable) throws {
        let encoder = addObject {
            TopLevelEncoder(path: codingPath, key: key, info: userInfo)
        }
        try keyPair.encode(to: encoder)
    }

    // MARK: Nested containers

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
        // This should never be executed, since the dictionaries which use this
        // class are created by the Codable implementation.
        // There is currently no way to encode super (and I'm not sure
        // that it even makes sense in this context) and we can't throw an error
        // so we just crash.
        fatalError()
    }

    func superEncoder(forKey key: Key) -> Encoder {
        // This should never be executed, since the dictionaries which use this
        // class are created by the Codable implementation.
        // It's here just in case
        addObject {
            TopLevelEncoder(path: codingPath + [key], key: key, info: userInfo)
        }
    }
}

// MARK: EncodedDataProvider

extension DictionaryKeyedEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        try objects.reduce(.empty) { try $0 + $1.encodedData() }
    }
}
