import Foundation

/**
 Decoding node used to decode dictionaries with integer or string keys.
 */
final class DictionaryKeyedDecoder<Key>: CodingPathNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    var allKeys: [Key] {
        fields.map { $0.key }
    }

    private var fields = [(key: Key, tag: Tag, value: Data)]()

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData]) throws {
        super.init(path: path, key: key, info: info)
        for (provider, _) in data {
            try decodeAllKeys(provider: provider)
        }
    }

    private func decodeAllKeys(provider: DecodingDataProvider) throws {
        while !provider.isAtEnd {
            try readKeyValuePair(provider: provider)
        }
    }

    private func readKeyValuePair(provider: DecodingDataProvider) throws {

        var key: (tag: Tag, data: Data)?
        var value: Data?
        while key == nil || value == nil {
            let (t, d) = try provider.getKeyedField()
            guard let codingKey = t.dictionaryKey else {
                throw ProtobufDecodingError.invalidDictionaryKey
            }
            switch codingKey {
            case .key:
                key = (tag: t, data: d)
            case .value:
                value = d
            }
        }

        let (keyTag, keyData) = key!
        let valueData = value!

        switch keyTag.wireType {
        case .lengthDelimited:
            let stringKey = try String(encodedData: keyData)
            guard let codingKey = Key(stringValue: stringKey) else {
                // Should never happen, since all strings are valid dictionary keys
                throw ProtobufDecodingError.invalidDictionaryKey
            }
            self.fields.append((key: codingKey, tag: keyTag, value: valueData))
        case .varint:
            let intKey = try Int(encodedData: keyData)
            guard let codingKey = Key(intValue: intKey) else {
                // Should never happen, since all integers are valid dictionary keys
                throw ProtobufDecodingError.invalidDictionaryKey
            }
            self.fields.append((key: codingKey, tag: keyTag, value: valueData))
        default:
            throw ProtobufDecodingError.invalidDictionaryKey
        }
    }

    func contains(_ key: Key) -> Bool {
        index(of: key) != nil
    }

    private func index(of key: Key) -> Int? {
        fields.firstIndex { $0.key.isEqual(to: key) }
    }

    private func removeData(for key: Key) -> (tag: Tag, key: Data)? {
        guard let i = index(of: key) else {
            return nil
        }
        let (_, tag, data) = fields.remove(at: i)
        return (tag, data)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        throw ProtobufDecodingError.notImplemented("Dictionary.KeyedContainer.decodeNil(forKey:)")
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {

        guard let (_, data) = removeData(for: key) else {
            throw ProtobufDecodingError.missingDictionaryKey
        }
        switch type {
        case let Primitive as BinaryDecodable.Type:
            return try Primitive.init(encodedData: data) as! T
        default:
            let provider = DecodingDataProvider(data: data)
            let decoder = TopLevelDecoder(path: codingPath + [key], key: key, info: userInfo, data: [(provider, nil)])
            let value = try type.init(from: decoder)
            return value
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw ProtobufDecodingError.notImplemented("Dictionary.KeyedContainer.nestedContainer(keyedBy:forKey:)")
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.notImplemented("Dictionary.KeyedContainer.nestedUnkeyedContainer(forKey:)")
    }

    func superDecoder() throws -> Decoder {
        throw ProtobufDecodingError.notImplemented("Dictionary.KeyedContainer.superDecoder()")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw ProtobufDecodingError.notImplemented("Dictionary.KeyedContainer.superDecoder(forKey:)")
    }


}
