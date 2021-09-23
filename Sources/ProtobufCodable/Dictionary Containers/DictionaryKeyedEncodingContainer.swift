import Foundation

final class DictionaryKeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]

    private var objects = [EncodedDataWrapper]()

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: Key) throws {
        fatalError()
    }

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
        let encoder = TopLevelEncodingContainer(codingPath: codingPath, userInfo: [:])
        try keyPair.encode(to: encoder)
        let data = try encoder.encodedDataWithoutField(includeLengthIfNeeded: true)
        // A key pair will never produce empty data, and is always encoded
        let wrapper = EncodedDataWrapper(data)
        objects.append(wrapper)
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

    func encodedObjects() throws -> [EncodedDataWrapper] {
        objects
    }
}
