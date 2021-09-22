import Foundation

final class KeyedContainerDecodingNode<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {

    var codingPath: [CodingKey]

    var allKeys: [Key] {
        fields.map { $0.key }
    }

    private var fields = [(key: Key, data: Data)]()

    init(codingPath: [CodingKey], provider: DecodingDataProvider) throws {
        self.codingPath = codingPath
        try decodeAllKeys(provider: provider)
    }

    private func decodeAllKeys(provider: DecodingDataProvider) throws {
        while !provider.isAtEnd {
            let tag = try Tag(from: provider)

            if let length = tag.valueLength {
                let data = try provider.getNextBytes(length)
                add(data, field: tag.field)
            } else if tag.wireType == .lengthDelimited {
                let length = try Int(from: provider)
                let data = try provider.getNextBytes(length)
                add(data, field: tag.field)
            } else {
                // Only choice left is varint
                let data = try provider.extractVarint()
                add(data, field: tag.field)
            }
        }
    }

    private func add(_ data: Data, field: Int) {
        guard let key = Key(intValue: field) else {
            print("Unknown field \(field): \(data.bytes)")
            return
        }
        fields.append((key, data))
    }

    // MARK: Decoding

    func contains(_ key: Key) -> Bool {
        fatalError()
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        fatalError()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        switch type {
        case let Primitive as BinaryDecodable.Type:
            guard let (_, data) = fields.last(where: { $0.key.intValue == key.intValue }) else {
                return Primitive.defaultValue as! T
            }
            return try Primitive.init(encodedData: data) as! T
        case let Dict as AnyDictionary.Type:
            let all = fields.filter({ $0.key.intValue == key.intValue }).map({ $0.data })

            // Not really needed to catch empty dicts, but maybe a bit more performant
            guard !all.isEmpty else {
                return Dict.init() as! T
            }
            let data = all.map { $0.count.variableLengthEncoding + $0 }.reduce(.empty, +)
            let decoder = DictionaryDecodingNode(codingPath: [], userInfo: [:], data: data)
            return try .init(from: decoder)
        default:
            let field = fields.last { $0.key.intValue == key.intValue }
            let data = field?.data ?? .empty
            let decoder = TopLevelDecodingContainer(codingPath: codingPath + [key], userInfo: [:], data: data)
            return try T.init(from: decoder)
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
