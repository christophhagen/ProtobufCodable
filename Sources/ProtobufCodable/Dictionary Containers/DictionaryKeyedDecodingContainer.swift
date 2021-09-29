import Foundation

//struct DictionaryCodingKey: CodingKey {
//
//    let intValue: Int?
//
//    let stringValue: String
//
//    init(
//}
/**
 Decoding node used to decode dictionaries with integer or string keys.
 */
final class DictionaryKeyedDecodingContainer<Key>: CodingPathNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    var allKeys: [Key] {
        fields.map { $0.key }
    }

    private var fields = [(key: Key, tag: Tag, value: Data)]()

    init(path: [CodingKey], key: CodingKey?, data: [FieldWithNilData]) throws {
        super.init(path: path, key: key)
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
            guard let codingKey = KeyValuePair<Int, Int>.CodingKeys(rawValue: t.field) else {
                fatalError()
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
                fatalError()
            }
            self.fields.append((key: codingKey, tag: keyTag, value: valueData))
        case .varint:
            let intKey = try Int(encodedData: keyData)
            guard let codingKey = Key(intValue: intKey) else {
                fatalError()
            }
            self.fields.append((key: codingKey, tag: keyTag, value: valueData))
        default:
            fatalError()
        }
    }

    func contains(_ key: Key) -> Bool {
        index(of: key) != nil
    }

    private func index(of key: Key) -> Int? {
        if let key = key.intValue {
            return fields.firstIndex { $0.key.intValue == key }
        }
        let key = key.stringValue
        return fields.firstIndex { $0.key.stringValue == key }
    }

    private func removeData(for key: Key) -> (tag: Tag, key: Data)? {
        guard let i = index(of: key) else {
            return nil
        }
        let (_, tag, data) = fields.remove(at: i)
        return (tag, data)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        fatalError()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {

        guard let (_, data) = removeData(for: key) else {
            fatalError()
        }
        switch type {
        case let Primitive as BinaryDecodable.Type:
            return try Primitive.init(encodedData: data) as! T
        default:
            let provider = DecodingDataProvider(data: data)
            let decoder = TopLevelDecodingContainer(path: codingPath + [key], key: key, info: [:], data: [(provider, nil)])
            let value = try type.init(from: decoder)
            return value
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }


}
