import Foundation

final class DictionaryKeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]

    private var encodedChildren = [Data]()

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
        let data = try encoder.getEncodedData()
        let length = data.count.variableLengthEncoding
        encodedChildren.append(length + data)
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

    func getEncodedData() throws -> Data {
        encodedChildren.reduce(.empty, +)
    }

    func encodedObjects() throws -> [Data] {
        encodedChildren
    }
}
