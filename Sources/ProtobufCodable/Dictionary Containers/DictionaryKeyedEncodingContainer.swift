import Foundation

/**
 A dictionary encoding node for cases where the dictionary keys are either integers or strings.
 */
final class DictionaryKeyedEncodingContainer<Key>: CodingPathNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var data: Data = .empty

    func encodeNil(forKey key: Key) throws {
        fatalError()
    }

    /**
     Encode a value for a dictionary key.
     */
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
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
        let encoder = TopLevelEncodingContainer(path: codingPath, key: key, userInfo: [:])
        try keyPair.encode(to: encoder)
        let data = try encoder.encodedData()
        self.data.append(data)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
    }

    func superEncoder() -> Encoder {
        fatalError()
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension DictionaryKeyedEncodingContainer: EncodedDataProvider {

    func encodedData() throws -> Data {
        data
    }
}
